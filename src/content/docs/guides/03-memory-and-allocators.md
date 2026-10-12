---
title: "03. 메모리 관리와 Allocator 실전 패턴"
description: "Zig 0.17.0의 메모리 모델, 표준 Allocator 종류(SafeAllocator, SmpAllocator, Arena, BufferFirst) 및 실무 패턴을 학습합니다."
---

# 03. 메모리 관리 및 Allocator 실무 패턴

Zig은 가비지 컬렉터(GC)나 숨겨진 런타임 제어기가 존재하지 않으며, 모든 동적 메모리 할당을 호출자가 명시적으로 전달하는 **`std.mem.Allocator`** 인터페이스를 통해 수행합니다.

---

## 1. Zig 메모리 철학: No Hidden Allocation

- **No Implicit Allocation**: 표준 라이브러리의 어떤 함수도 호출자가 전달한 할당자 없이는 힙 메모리를 할당하지 않습니다.
- **Explicit Lifecycle**: 할당된 메모리는 호출자가 명시적으로 해제해야 하며, `defer`를 활용해 결정론적(deterministic) 정리를 보장합니다.

---

## 2. Zig 0.17.0 표준 Allocator의 종류와 용도

| 할당자 (Allocator) | 설명 | 주요 사용처 |
|---|---|---|
| `init.gpa` / `std.heap.SafeAllocator` | 스레드 안전한 디버그/런타임 할당자. 카나리 보호, AllocFooter 및 누수 감지 내장 | 개발 및 디버그 빌드 최상위 진입점 (`main.zig`) |
| `std.heap.SmpAllocator` / `smp_allocator` | 멀티스레드 환경에 최적화된 고성능 SMP 할당자 | 고성능 서버, 멀티스레딩 프로덕션 런타임 |
| `std.heap.BufferFirstAllocator` | 스택 버퍼를 먼저 사용하고 용량 초과 시 힙으로 폴백하는 소형 버퍼 최적화 할당자 | 단기 버퍼 연산, 문자열 조작 |
| `std.heap.ArenaAllocator` | 하위 할당자를 감싸서 여러 번 할당한 뒤, 마지막에 단 한 번의 호출로 일괄 해제(batch free) | 요청 단위 라이프사이클(HTTP 요청, AST 파서, CLI 실행) |
| `std.heap.FixedBufferAllocator` | 고정 크기 스택/정적 버퍼 위에서 동작하는 할당자. 힙을 전혀 사용하지 않음 | 임베디드, 실시간 시스템, 임시 포맷팅 |
| `std.heap.page_allocator` | OS 커널의 가상 메모리 페이지를 직접 요청하는 저수준 할당자 | 대용량 버퍼 할당, 커스텀 할당자 구현의 백엔드 |
| `std.testing.allocator` | 테스트 전용 할당자로, 테스트 종료 시 누수 발생 여부를 자동 감지 | `test` 블록 내부 |

---

## 3. SafeAllocator 및 표준 Allocator 실전 사용 (v0.17.0)

`main.zig`:
```zig
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    // 1. std.process.Init에서 프로세스 할당자 취득 (v0.17.0)
    const gpa = init.gpa;

    // 2. 동적 배열(ArrayList) .empty 관용구 및 명시적 주입
    var list: std.ArrayList(u32) = .empty;
    defer list.deinit(gpa); // 스코프 탈출 시 메모리 해제

    try list.append(gpa, 10);
    try list.append(gpa, 20);
    try list.append(gpa, 30);

    for (list.items, 0..) |item, idx| {
        std.debug.print("list[{d}] = {d}\n", .{ idx, item });
    }
}
```

---

## 4. ArenaAllocator를 활용한 빠른 일괄 해제

웹 서버의 요청 처리나 CLI 파서처럼 수많은 작은 객체를 할당한 뒤 요청이 끝나면 한꺼번에 버리는 경우, Arena 패턴이 가장 효율적입니다.

```zig
const std = @import("std");

pub fn processRequest(parent_allocator: std.mem.Allocator) !void {
    // ArenaAllocator 초기화 (하위 할당자를 감쌈)
    var arena = std.heap.ArenaAllocator.init(parent_allocator);
    defer arena.deinit(); // 함수 종료 시 아레나에 속한 모든 메모리 일괄 해제!

    const allocator = arena.allocator();

    // 아래에서 할당한 객체들은 각각 deinit할 필요가 없음
    const buffer = try allocator.alloc(u8, 1024);
    _ = buffer;

    var map = std.StringHashMap(u32).init(allocator);
    try map.put("key1", 100);
    try map.put("key2", 200);

    // arena.deinit() 하나로 buffer와 map의 모든 힙 메모리가 0.001ms만에 일괄 반환됨
}

test "arena allocation" {
    try processRequest(std.testing.allocator);
}
```

---

## 5. FixedBufferAllocator: 힙 할당 없는 무할당(Zero-alloc) 프로그래밍

```zig
const std = @import("std");

test "fixed buffer allocator" {
    // 스택에 256바이트 버퍼 확보
    var stack_buffer: [256]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&stack_buffer);
    const allocator = fba.allocator();

    const slice = try allocator.alloc(u32, 10);
    for (slice, 0..) |*item, i| {
        item.* = @intCast(i * 10);
    }

    try std.testing.expectEqual(@as(u32, 50), slice[5]);
}
```
