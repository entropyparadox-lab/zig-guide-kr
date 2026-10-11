---
title: "09. C ABI 및 인라인 어셈블리 레퍼런스 (v0.16.0)"
description: "Zig 0.16.0 공식 레퍼런스 - extern fn, export, 호출 규약(callconv), 인라인 어셈블리 문법."
---

# 09. C ABI 및 인라인 어셈블리 레퍼런스

---

## 1. C 호출 규약 및 함수 내보내기 (`export` & `callconv`)

C ABI와 호환되는 함수를 내보내려면 `export` 키워드와 `callconv(.C)`를 지정합니다:

```zig
export fn zig_add(a: i32, b: i32) callconv(.c) i32 {
    return a + b;
}

test "export c function test" {
    const res = zig_add(10, 20);
    _ = res;
}
```

---

## 2. 외부 C 함수 선언 (`extern fn`)

외부 C 라이브러리의 함수를 선언할 때 `extern` 키워드를 사용합니다:

```zig
extern "c" fn puts(str: [*:0]const u8) c_int;

test "extern function declaration" {
    _ = puts;
}
```

---

## 3. C 호환 구조체 (`extern struct`)

C 언어의 메모리 레이아웃 및 패딩 규칙과 100% 호환되는 구조체는 `extern struct`로 정의합니다:

```zig
const std = @import("std");

const CHeader = extern struct {
    magic: u32,
    version: u16,
    flags: u16,
};

test "extern struct size" {
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(CHeader));
}
```
