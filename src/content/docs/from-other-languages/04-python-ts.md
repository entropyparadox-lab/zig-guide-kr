---
title: "Python/TypeScript 개발자를 위한 Zig 가이드"
description: "동적 언어에서 정적 시스템 언어로 - 스택 vs 힙 메모리 모델, null/undefined 안전성, C 확장 모듈 제작."
---

# Python/TypeScript 개발자를 위한 Zig 가이드

Python과 TypeScript 같은 고수준 언어는 뛰어난 생산성을 자랑하지만, CPU 집약적인 연산이나 메모리 최적화, 저지연 I/O가 필요한 영역에서는 한계에 부딪힙니다.

이 챕터에서는 인터프리터 및 JIT 환경에서 **하드웨어 제어 중심의 Zig 시스템 프로그래밍**으로 전환할 때 알아야 할 핵심 원리를 짚어봅니다.

---

## 📌 핵심 멘탈 모델 매핑

| Python / TypeScript | Zig 대응 개념 | 핵심 이해 포인트 |
|---|---|---|
| 동적 타이핑 (`any`, `dict`) | 정적 강타입 (`struct`, `u32`, `f64`) | 모든 변수의 메모리 크기와 타입이 컴파일 시점에 결정됨 |
| `null` & `undefined` | 옵셔널(`?T`) & `undefined` 키워드 | Zig의 `undefined`는 초기화 안 된 원시 메모리 상태를 뜻하며, 안전한 null은 `?T`로만 표현 |
| 자동 메모리 관리 / GC | `std.mem.Allocator` | 객체 생성 시 메모리 수명을 명시적으로 선언 (`defer allocator.free()`) |
| `try...catch` 예외 | `try` & 에러 유니온 (`!T`) | 스택 트레이스 풀기 없이 값으로 취급되는 고속 에러 모델 |
| `async` / `await` | `std.Thread` 및 OS I/O | 런타임 이벤트 루프 대신 커널 스레드 및 논블로킹 소켓 직접 제어 |
| Python C 확장 / Node-API (C++) | C ABI 호환 공유 라이브러리 (`.so`, `.dylib`, `.dll`) | `export fn`으로 파이썬/노드용 초고속 네이티브 모듈을 손쉽게 작성 |

---

## 1. `undefined`와 옵셔널(`?T`)의 명확한 차이

TypeScript에서 `undefined`는 일종의 값(Value)이지만, Zig에서 `undefined`는 **"이 메모리는 아직 초기화되지 않았으므로 쓰레기 값이 들어있다"**는 하드웨어 수준의 선언입니다.

```zig
const std = @import("std");

test "optional vs undefined in zig" {
    // 1. null이 가능한 변수는 ?T로 선언
    var optional_name: ?[]const u8 = null;
    optional_name = "Alice";

    // 2. undefined는 성능을 위해 메모리 초기화를 건너뛸 때 사용
    var buffer: [16]u8 = undefined;
    @memset(&buffer, 0);

    try std.testing.expectEqualStrings("Alice", optional_name.?);
    try std.testing.expectEqual(@as(u8, 0), buffer[0]);
}
```

---

## 2. Python / Node.js용 초고속 네이티브 C 확장 모듈 만들기

Python의 `ctypes` 또는 Node.js의 `ffi-napi`에서 직접 호출할 수 있는 네이티브 C ABI 함수를 Zig으로 3줄 만에 작성할 수 있습니다.

```zig
const std = @import("std");

// Python/Node에서 호출 가능한 C ABI 함수
export fn fast_fibonacci(n: u32) callconv(.C) u64 {
    if (n <= 1) return n;
    var a: u64 = 0;
    var b: u64 = 1;
    var i: u32 = 2;
    while (i <= n) : (i += 1) {
        const next = a + b;
        a = b;
        b = next;
    }
    return b;
}

test "fast fibonacci test" {
    try std.testing.expectEqual(@as(u64, 55), fast_fibonacci(10));
}
```

### 공유 라이브러리로 빌드:
```bash
zig build-lib -dynamic fast_fib.zig -O ReleaseFast
# Linux: libfast_fib.so 생성
# macOS: libfast_fib.dylib 생성
# Windows: fast_fib.dll 생성
```

### Python에서 바로 호출하기 (`ctypes`):
```python
import ctypes

lib = ctypes.CDLL("./libfast_fib.so")
lib.fast_fibonacci.argtypes = [ctypes.c_uint32]
lib.fast_fibonacci.restype = ctypes.c_uint64

print(lib.fast_fibonacci(10)) # 55
```

---

## 💡 요약

- Zig은 복잡한 런타임 없이 C 언어와 100% 호환되므로, Python/TypeScript 프로젝트의 성능 병목을 해결하는 가장 현대적인 네이티브 가속 언어로 활용할 수 있습니다.
