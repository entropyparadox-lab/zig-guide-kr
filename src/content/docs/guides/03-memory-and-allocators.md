---
title: "03. 메모리 관리와 Allocator 실전 패턴"
description: "숨겨진 동적 할당 없는 Zig의 철학, 표준 Allocator 종류 및 실무 메모리 관리 패턴을 학습합니다."
---

# 03. 메모리 관리와 Allocator 실전 패턴

Zig에는 가비지 컬렉터(GC)나 숨겨진 런타임 할당(Hidden Allocations)이 존재하지 않습니다. 모든 힙 메모리 할당은 명시적으로 전달받은 `std.mem.Allocator`를 통해 이루어집니다.

---

## 1. Zig의 메모리 철학

- **No Hidden Allocations**: 표준 라이브러리의 어떤 함수도 `Allocator`를 인자로 받지 않고는 힙 메모리를 몰래 할당하지 않습니다.
- **Explicit Lifecycle**: 할당된 메모리는 호출자가 명시적으로 해제해야 하며, `defer`를 활용해 누수를 방지합니다.

---

## 2. 표준 Allocator의 종류와 용도

| 할당자 (Allocator) | 설명 | 주요 사용처 |
|---|---|---|
| `std.heap.GeneralPurposeAllocator` (GPA) | 안전한 범용 힙 할당자. 메모리 누수 감지 및 use-after-free 감지 기능 내장 | 애플리케이션 최상위 진입점(`main.zig`) |
| `std.heap.ArenaAllocator` | 다른 할당자를 감싸서 여러 번 할당한 뒤, 마지막에 단 한 번의 호출로 일괄 해제(batch free) | 요청 단위 라이프사이클(HTTP 요청, 컴파일러 AST 파싱) |
| `std.heap.FixedBufferAllocator` | 고정 크기 스택/정적 버퍼 위에서 동작하는 할당자. 힙을 사용하지 않음 | 임베디드, 실시간 시스템, 임시 문자열 포맷팅 |
| `std.heap.page_allocator` | OS 커널의 가상 메모리 페이지를 직접 요청하는 저수준 할당자 | 대용량 버퍼 할당, 커스텀 할당자 구현의 백엔드 |
| `std.testing.allocator` | 테스트 전용 할당자로, 테스트 종료 시 누수 발생 여부를 자동 감지 | `test` 블록 내부 |

---

## 3. GeneralPurposeAllocator (GPA) 실전 사용

`main.zig`:
```zig
const std = @import("std");

pub fn main() !void {
    // 1. GPA 초기화
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            std.debug.print("WARNING: Memory leak detected!\n", .{});
        }
    }
    const allocator = gpa.allocator();

    // 2. 동적 배열(ArrayList) 사용
    var list = std.ArrayList(u32).init(allocator);
    defer list.deinit(); // 스코프 탈출 시 메모리 해제

    try list.append(10);
    try list.append(20);
    try list.append(30);

    for (list.items) |item| {
        std.debug.print("Item: {d}\n", .{item});
    }
}
```

---

## 4. ArenaAllocator를 활용한 빠른 일괄 해제

웹 서버의 요청 처리나 CLI 파서처럼 수많은 작은 객체를 할당한 뒤 요청이 끝나면 모두 버리는 경우, Arena 패턴이 가장 효율적입니다.

```zig
const std = @import("std");

fn processRequest(backing_allocator: std.mem.Allocator) !void {
    // Arena 생성: backing_allocator로부터 큰 청크를 받아 내부 분할
    var arena = std.heap.ArenaAllocator.init(backing_allocator);
    defer arena.deinit(); // 여기서 모든 할당 메모리가 한 번에 해제됨!

    const arena_allocator = arena.allocator();

    // 개별 deinit 호출 없이 자유롭게 할당
    const str1 = try arena_allocator.dupe(u8, "Hello");
    const str2 = try arena_allocator.dupe(u8, "World");
    const formatted = try std.fmt.allocPrint(arena_allocator, "{s}, {s}!", .{ str1, str2 });

    std.debug.print("{s}\n", .{formatted});
}
```

---

## 5. 단위 테스트에서의 메모리 누수 검증

`std.testing.allocator`를 사용하면 테스트가 끝날 때 메모리 누수가 발생하면 테스트가 자동으로 실패합니다.

```zig
const std = @import("std");
const testing = std.testing;

test "detect memory leak in test" {
    const allocator = testing.allocator;

    const memory = try allocator.alloc(u8, 100);
    defer allocator.free(memory); // 이것을 주석 처리하면 zig test가 FAIL함

    @memset(memory, 'A');
    try testing.expectEqual(@as(u8, 'A'), memory[0]);
}
```

---

## 💡 요약

- 상위 레이어에서 Allocator를 생성하고, 하위 함수나 구조체에는 `allocator: std.mem.Allocator`를 주입(Dependency Injection)하는 것이 Zig의 관례입니다.
- `defer allocator.free(...)` 또는 `defer container.deinit()`를 할당 직후에 선언하여 메모리 수명을 완벽히 통제하세요.
