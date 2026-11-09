---
title: "11. I/O 스트림 및 파일 시스템 레퍼런스 (v0.17.0)"
description: "Zig 0.17.0 공식 레퍼런스 - std.Io.Reader/Writer 인터페이스, std.Io.File, 버퍼 I/O."
---

# 11. I/O 스트림 및 파일 시스템 레퍼런스

---

## 1. `Reader` 및 `Writer` 인터페이스

Zig의 I/O는 `std.Io.Reader`와 `std.Io.Writer` 인터페이스를 사용합니다. 메모리 버퍼만 사용하는 Writer는 별도 I/O 구현 없이 동작합니다.

```zig
const std = @import("std");

test "fixed buffer stream io" {
    var buffer: [64]u8 = undefined;
    var writer: std.Io.Writer = .fixed(&buffer);

    try writer.print("Number: {d}, Hex: 0x{X}", .{ 42, 255 });

    const written_data = writer.buffered();
    try std.testing.expectEqualStrings("Number: 42, Hex: 0xFF", written_data);
}
```

---

## 2. 파일 I/O 및 디렉터리 연산 (`std.Io.Dir`)

```zig
const std = @import("std");

test "file read write operations" {
    const testing = std.testing;
    const io = testing.io;
    var test_dir = testing.tmpDir(.{});
    const dir = test_dir.dir;
    defer test_dir.cleanup();

    // 파일 쓰기
    const file = try dir.createFile(io, "hello.txt", .{});
    defer file.close(io);
    try file.writePositionalAll(io, "Zig I/O is fast and explicit\n", 0);

    // 파일 읽기
    var read_buf: [128]u8 = undefined;
    const read_file = try dir.openFile(io, "hello.txt", .{});
    defer read_file.close(io);
    const bytes_read = try read_file.readPositionalAll(io, &read_buf, 0);

    try testing.expectEqualStrings("Zig I/O is fast and explicit\n", read_buf[0..bytes_read]);
}
```
