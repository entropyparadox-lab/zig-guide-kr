---
title: "10. 스레드 및 아토믹 연산 레퍼런스 (v0.16.0)"
description: "Zig 0.16.0 공식 레퍼런스 - std.Thread, std.atomic, Mutex, Condition Variable."
---

# 10. 스레드 및 아토믹 연산 레퍼런스

---

## 1. `std.Thread` 스레드 생성과 조인

```zig
const std = @import("std");

fn workerThread(id: usize, out_val: *usize) void {
    out_val.* = id * 10;
}

test "spawn and join thread" {
    var result: usize = 0;
    const thread = try std.Thread.spawn(.{}, workerThread, .{ @as(usize, 5), &result });
    thread.join();

    try std.testing.expectEqual(@as(usize, 50), result);
}
```

---

## 2. 원자적 연산 (`std.atomic.Value`)

Zig은 표준적인 메모리 순서(Memory Ordering: `.monotonic`, `.acquire`, `.release`, `.seq_cst`)를 지원합니다.

```zig
const std = @import("std");

test "atomic value operations" {
    var counter = std.atomic.Value(u32).init(0);

    _ = counter.fetchAdd(1, .monotonic);
    _ = counter.fetchAdd(5, .monotonic);

    const final_val = counter.load(.acquire);
    try std.testing.expectEqual(@as(u32, 6), final_val);
}
```

---

## 3. 동기화 프리미티브 (`std.Thread.Mutex`)

```zig
const std = @import("std");

test "mutex locking" {
    var mutex = std.Thread.Mutex{};
    var shared_data: u32 = 0;

    {
        mutex.lock();
        defer mutex.unlock();
        shared_data += 42;
    }

    try std.testing.expectEqual(@as(u32, 42), shared_data);
}
```
