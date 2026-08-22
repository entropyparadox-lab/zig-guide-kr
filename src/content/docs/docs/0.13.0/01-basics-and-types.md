---
title: "01. 기본 문법과 타입 시스템 (v0.13.0)"
description: "Zig 0.13.0 공식 레퍼런스 - 변수 선언, 원시 타입, 정수, 부동소수점, 배열 및 리터럴."
---

# 01. 기본 문법과 타입 시스템

---

## 1. 변수와 상수 선언 (`const` 및 `var`)

Zig에서 모든 식별자는 `const`(상수) 또는 `var`(가변 변수)로 선언됩니다. 기본값으로 `const` 사용이 권장됩니다.

```zig
test "variables and constants" {
    const constant_value: i32 = 100;
    var mutable_value: u32 = 50;
    mutable_value += 10;

    // 타입 추론 (Type Inference)
    const inferred_constant = @as(u8, 255);

    _ = constant_value;
    _ = inferred_constant;
}
```

초기화되지 않은 변수를 선언할 때는 반드시 `undefined`를 명시해야 합니다:

```zig
test "undefined variable" {
    var buffer: [1024]u8 = undefined;
    buffer[0] = 42;
}
```

---

## 2. 원시 타입 (Primitive Types)

### 정수 타입 (Integers)
- 부호 있는 정수: `i8`, `i16`, `i32`, `i64`, `i128`, `isize`
- 부호 없는 정수: `u8`, `u16`, `u32`, `u64`, `u128`, `usize`
- 임의 비트 정수: `u1`부터 `u65535`까지 임의의 비트 크기 정수를 직접 정의 가능 (예: `u3`, `i7`)

### 부동소수점 타입 (Floats)
- `f16`, `f32`, `f64`, `f80`, `f128`, `c_longdouble`

### 기타 기본 타입
- `bool`: `true` 또는 `false`
- `void`: 크기가 0인 타입
- `noreturn`: 반환되지 않는 함수(예: 무한 루프, panic)의 반환 타입
- `type`: 컴파일 시점의 타입 자체를 나타내는 메타 타입

---

## 3. 배열 (Arrays)

배열은 고정 크기의 동일 타입 원소들의 연속된 집합입니다. 문법: `[N]T`

```zig
const std = @import("std");

const numbers = [_]i32{ 1, 2, 3, 4, 5 }; // 컴파일러가 길이 자동 계산
const array_len = numbers.len; // 5

test "array indexing" {
    try std.testing.expectEqual(@as(i32, 1), numbers[0]);
    try std.testing.expectEqual(@as(i32, 5), numbers[4]);
}
```

---

## 4. 문자열 리터럴 (String Literals)

Zig에서 문자열 리터럴은 **null 종단된 불변 바이트 배열에 대한 단일 포인터**(`*const [N:0]u8`)입니다. 슬라이스(`[]const u8`)로 자동 형변환(Coercion)됩니다.

```zig
const hello: []const u8 = "Hello, Zig!";
```
