---
title: "08. 메모리 관리 및 Allocator 레퍼런스 (v0.13.0)"
description: "Zig 0.13.0 공식 레퍼런스 - std.mem.Allocator 인터페이스, 메모리 정렬, GPA, Arena, PageAllocator 스펙."
---

# 08. 메모리 관리 및 Allocator 레퍼런스

---

## 1. `std.mem.Allocator` 인터페이스

Zig에서 메모리 할당은 `std.mem.Allocator` 가상 테이블 구조체를 통해 수행됩니다.

```zig
const std = @import("std");

test "allocator basic operations" {
    const allocator = std.testing.allocator;

    // 단일 항목 할당
    const ptr = try allocator.create(u32);
    defer allocator.destroy(ptr);
    ptr.* = 100;

    // 슬라이스(배열) 할당
    const slice = try allocator.alloc(u8, 64);
    defer allocator.free(slice);
    @memset(slice, 0);

    try std.testing.expectEqual(@as(u32, 100), ptr.*);
    try std.testing.expectEqual(@as(usize, 64), slice.len);
}
```

---

## 2. 메모리 정렬 (Alignment)

모든 포인터 타입은 정렬 정보(`align(N)`)를 타입 시스템에 인코딩합니다.

```zig
const std = @import("std");

test "aligned memory allocation" {
    const allocator = std.testing.allocator;

    // 16바이트 정렬된 메모리 할당
    const aligned_slice = try allocator.alignedAlloc(u8, 16, 64);
    defer allocator.free(aligned_slice);

    try std.testing.expect(@intFromPtr(aligned_slice.ptr) % 16 == 0);
}
```

---

## 3. 메모리 재할당 및 크기 조정

`allocator.realloc` 및 `allocator.resize`를 통해 기존 메모리 블록을 확장하거나 축소할 수 있습니다.

```zig
const std = @import("std");

test "realloc operation" {
    const allocator = std.testing.allocator;

    var buf = try allocator.alloc(u8, 10);
    defer allocator.free(buf);

    @memset(buf, 'x');

    buf = try allocator.realloc(buf, 20);
    try std.testing.expectEqual(@as(usize, 20), buf.len);
    try std.testing.expectEqual(@as(u8, 'x'), buf[0]);
}
```
