---
title: "C/C++ 개발자를 위한 Zig 가이드"
description: "전처리기 매크로 대체, malloc 대신 Allocator, 미정의 동작(UB) 방어, @cImport와 zig cc 활용법."
---

# C/C++ 개발자를 위한 Zig 가이드

C와 C++에 익숙한 개발자에게 Zig은 **가장 친숙하면서도 현대적인 대안**입니다. 불필요한 숨겨진 제어 흐름 없이 C의 직관적인 메모리 모델을 유지하면서도, 전처리기 지옥과 미정의 동작(UB)을 근본적으로 해결합니다.

---

## 📌 핵심 멘탈 모델 매핑

| C / C++ 개념 | Zig 대응 개념 | 핵심 차이점 및 개선 사항 |
|---|---|---|
| `#define`, 매크로 | `comptime` 변수 / 함수 | 완전히 타입 안전하며 동일한 Zig 문법으로 컴파일타임 연산 수행 |
| `malloc()` / `free()` | `std.mem.Allocator` | 전역 힙 대신 명시적으로 할당자 인터페이스를 주입받아 누수 추적 가능 |
| 댕글링 포인터 / 버퍼 오버플로우 | 슬라이스 (`[]T`) & `ReleaseSafe` | 포인터와 길이를 묶어 바운드 체크 자동 수행 |
| `typedef struct` / `class` | `struct` | 상속이나 숨겨진 vtable 없이 명시적인 메서드 및 인터페이스 패턴 |
| `NULL` 포인터 | 옵셔널 타입 (`?*T`) | 컴파일 시점에 null 역참조(Null Pointer Dereference) 차단 |
| `setjmp`/`longjmp`, C++ Exception | 에러 유니온 (`!T`) & `errdefer` | 숨겨진 스택 언와인딩(Stack Unwinding) 없이 정수 레벨의 제로 비용 에러 |
| `Makefile` / `CMake` | `build.zig` | 별도 빌드 언어 없이 Zig 코드로 빌드 및 C 소스/헤더 컴파일 제어 |

---

## 1. 전처리기 매크로(`macro`) vs `comptime`

C의 매크로는 단순 텍스트 치환이라 디버깅과 타입 검사가 불가능하지만, Zig은 완전한 컴파일타임 코드 실행을 제공합니다.

### C 코드
```c
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define BUFFER_SIZE 1024
```

### Zig 코드
```zig
const std = @import("std");

const buffer_size: usize = 1024;

fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

test "comptime max vs c macro" {
    const val = max(i32, 10, 20);
    try std.testing.expectEqual(@as(i32, 20), val);
}
```

---

## 2. 메모리 할당: 전역 `malloc` vs 명시적 `Allocator`

C에서는 `malloc`이 실패해도 체크를 누락하기 쉽고 메모리 누수 감지가 어렵지만, Zig은 `std.heap.GeneralPurposeAllocator`로 누수를 자동 보고합니다.

```zig
const std = @import("std");

test "explicit allocator allocation" {
    const allocator = std.testing.allocator;

    // C의 malloc(sizeof(int) * 10)에 대응
    const numbers = try allocator.alloc(i32, 10);
    defer allocator.free(numbers); // C의 free()에 대응

    for (numbers, 0..) |*num, i| {
        num.* = @intCast(i * 10);
    }

    try std.testing.expectEqual(@as(i32, 90), numbers[9]);
}
```

---

## 3. C 헤더 직접 임포트 (`@cImport`)

별도의 바인딩 생성 도구 없이 C 헤더(`.h`)를 즉시 가져와 호출할 수 있습니다:

```zig
const std = @import("std");

const c = @cImport({
    @cInclude("stdlib.h");
    @cInclude("string.h");
});

test "c standard library interop" {
    const ptr = c.malloc(32);
    defer c.free(ptr);

    if (ptr != null) {
        _ = c.memset(ptr, 0, 32);
    }
}
```

---

## 4. Zig을 C 컴파일러로 활용 (`zig cc`)

기존 C/C++ 프로젝트를 컴파일하거나 크로스 컴파일할 때 Clang/GCC 대신 `zig cc`를 바로 사용할 수 있습니다:

```bash
# C 소스 컴파일
zig cc -O3 -o my_app main.c

# Windows .exe로 크로스 컴파일
zig cc -target x86_64-windows -o my_app.exe main.c
```
