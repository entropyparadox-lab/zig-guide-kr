---
title: "04. 포인터, 슬라이스, 메모리 (v0.16.0)"
description: "Zig 0.16.0 공식 레퍼런스 - 단일 포인터(*T), 다중 포인터([*]T), 슬라이스([]T), 센티널 포인터([*:0]T)."
---

# 04. 포인터, 슬라이스, 메모리 모델

---

## 1. 포인터 타입 종류

| 문법 | 명칭 | 설명 |
|---|---|---|
| `*T` | 단일 아이템 포인터 | 정확히 하나의 `T` 객체를 가리킴 (포인터 연산 불가) |
| `[*]T` | 다중 아이템 포인터 | 알 수 없는 개수의 연속된 `T` 메모리를 가리킴 (포인터 연산 가능) |
| `[]T` | 슬라이스 (Slice) | 포인터(`[*]T`)와 길이(`len: usize`)를 묶은 안전한 뷰 |
| `[*:0]T` | 센티널 종단 포인터 | 0(null)으로 끝나는 C 호환 문자열/배열 포인터 |

---

## 2. 슬라이스 (Slices)

슬라이스는 배열이나 메모리 버퍼의 일부 구간을 안전하게 참조합니다:

```zig
const std = @import("std");

test "slice operations" {
    var array = [_]i32{ 10, 20, 30, 40, 50 };
    const slice = array[1..4]; // [20, 30, 40]

    try std.testing.expectEqual(@as(usize, 3), slice.len);
    try std.testing.expectEqual(@as(i32, 20), slice[0]);
}
```
