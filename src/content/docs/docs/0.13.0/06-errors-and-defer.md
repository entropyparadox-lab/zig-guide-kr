---
title: "06. 에러 처리 및 defer (v0.13.0)"
description: "Zig 0.13.0 공식 레퍼런스 - error sets, error unions, try, catch, defer, errdefer."
---

# 06. 에러 처리 및 defer

---

## 1. 에러 세트 및 에러 유니온

```zig
const std = @import("std");

const MyError = error{
    BadInput,
    Timeout,
};

fn doTask(value: i32) MyError!i32 {
    if (value < 0) return error.BadInput;
    return value * 2;
}
```

---

## 2. `defer` 및 `errdefer`

```zig
fn example(should_fail: bool) !void {
    defer std.debug.print("Always runs on exit\n", .{});
    errdefer std.debug.print("Only runs on error return\n", .{});

    if (should_fail) return error.Failed;
}
```
