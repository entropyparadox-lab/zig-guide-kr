---
title: "02. 제어 흐름 및 함수 (v0.13.0)"
description: "Zig 0.13.0 공식 레퍼런스 - if문, while/for 반복문, switch문 및 함수 선언 규칙."
---

# 02. 제어 흐름 및 함수

---

## 1. 조건문 (`if`)

Zig의 `if`문은 구문(Statement)이자 식(Expression)으로 동작합니다. 조건식은 반드시 불리언(`bool`) 타입이어야 합니다(0이나 포인터의 암시적 불리언 변환 불가).

```zig
const std = @import("std");

fn checkValue(x: i32) []const u8 {
    // 식(Expression)으로 활용
    const message = if (x > 0) "positive" else "non-positive";
    return message;
}
```

---

## 2. 반복문 (`while` 및 `for`)

### `while` 루프
`while` 루프는 조건부 실행 및 연속 식(continue expression)을 지원합니다:

```zig
var i: u32 = 0;
while (i < 5) : (i += 1) {
    // i가 0부터 4까지 순회
}
```

### `for` 루프 (v0.13.0 멀티-오브젝트 순회)
Zig 0.13.0의 `for`는 하나 이상의 슬라이스/배열을 동시에 인덱스와 함께 순회할 수 있습니다:

```zig
const std = @import("std");

test "multi-object for loop" {
    const items = [_]u8{ 'a', 'b', 'c' };
    const values = [_]u32{ 10, 20, 30 };

    for (items, values, 0..) |item, val, idx| {
        std.debug.print("Index {d}: {c} -> {d}\n", .{ idx, item, val });
    }
}
```

---

## 3. 분기문 (`switch`)

`switch`는 모든 가능한 케이스를 망라(Exhaustive)해야 합니다.

```zig
const std = @import("std");

fn categorizeNumber(val: u8) []const u8 {
    return switch (val) {
        0 => "zero",
        1...9 => "single digit",
        10...99 => "double digit",
        else => "large number",
    };
}
```

---

## 4. 함수 선언 (Functions)

함수는 `fn` 키워드로 선언되며, 모든 파라미터는 기본적으로 불변(`const`)입니다.

```zig
pub fn add(a: i32, b: i32) i32 {
    return a + b;
}
```
