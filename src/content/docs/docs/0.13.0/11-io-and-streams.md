---
title: "11. I/O 스트림 및 파일 시스템 레퍼런스 (v0.13.0)"
description: "Zig 0.13.0 공식 레퍼런스 - Reader/Writer 인터페이스, std.fs.File, 버퍼 I/O."
---

# 11. I/O 스트림 및 파일 시스템 레퍼런스

---

## 1. `Reader` 및 `Writer` 인터페이스

Zig의 모든 I/O는 `read` 및 `write` 메서드를 제공하는 제네릭 인터페이스를 기반으로 구축됩니다.

```zig
const std = @import("std");

test "fixed buffer stream io" {
    var buffer: [64]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);

    const writer = fbs.writer();
    try writer.print("Number: {d}, Hex: 0x{X}", .{ 42, 255 });

    const written_data = fbs.getWritten();
    try std.testing.expectEqualStrings("Number: 42, Hex: 0xFF", written_data);
}
```

---

## 2. 파일 I/O 및 디렉터리 연산 (`std.fs`)

```zig
const std = @import("std");

test "file read write operations" {
    const testing = std.testing;
    const test_dir = std.testing.tmpDir(.{});
    var dir = test_dir.dir;
    defer test_dir.cleanup();

    // 파일 쓰기
    const file = try dir.createFile("hello.txt", .{});
    defer file.close();
    try file.writeAll("Zig I/O is fast and explicit\n");

    // 파일 읽기
    var read_buf: [128]u8 = undefined;
    const read_file = try dir.openFile("hello.txt", .{});
    defer read_file.close();
    const bytes_read = try read_file.readAll(&read_buf);

    try testing.expectEqualStrings("Zig I/O is fast and explicit\n", read_buf[0..bytes_read]);
}
```
