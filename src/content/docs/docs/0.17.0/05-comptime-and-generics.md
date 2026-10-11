---
title: "05. Comptime 및 제네릭 (v0.16.0)"
description: "Zig 0.16.0 공식 레퍼런스 - comptime 키워드, 타입 반환 함수, @typeInfo 리플렉션."
---

# 05. Comptime 및 제네릭

---

## 1. `comptime` 키워드

Zig에서 `comptime`은 표현식이나 파라미터가 반드시 컴파일 시점에 계산되어야 함을 나타냅니다.

```zig
fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

test "comptime generic function" {
    const val = max(i32, 10, 20);
    _ = val;
}
```

---

## 2. 컴파일 타임 타입 검사

`@typeInfo`와 `@compileError`를 통해 제네릭 타입 제약 조건을 검사할 수 있습니다:

```zig
fn expectInt(comptime T: type) void {
    if (@typeInfo(T) != .int) {
        @compileError("Only integer types are supported!");
    }
}
```
