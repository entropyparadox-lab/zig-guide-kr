---
title: "09. 웹 네트워킹과 JSON 직렬화 실전"
description: "std.http 클라이언트, TCP 소켓 통신, JSON 파싱 및 직렬화 기법을 학습합니다."
---

# 09. 웹 네트워킹과 JSON 직렬화 실전

Zig 표준 라이브러리는 외부 C 라이브러리(libcurl, cJSON 등)에 의존하지 않고도 **완전한 순수 Zig 구현의 HTTP 클라이언트(`std.http.Client`)와 JSON 파서(`std.json`)**를 제공합니다.

---

## 1. JSON 직렬화 및 역직렬화 (`std.json`)

Zig의 컴파일 타임 리플렉션을 통해 모든 구조체는 별도의 어노테이션이나 매크로 없이 즉시 JSON으로 변환할 수 있습니다.

```zig
const std = @import("std");

const UserProfile = struct {
    id: u64,
    username: []const u8,
    is_admin: bool,
};

test "json stringify and parse" {
    const allocator = std.testing.allocator;

    const user = UserProfile{
        .id = 1001,
        .username = "alice",
        .is_admin = true,
    };

    // 1. JSON 직렬화 (Stringify)
    const json_str = try std.json.Stringify.valueAlloc(allocator, user, .{});
    defer allocator.free(json_str);

    // 2. JSON 역직렬화 (Parse)
    const parsed = try std.json.parseFromSlice(
        UserProfile,
        allocator,
        json_str,
        .{},
    );
    defer parsed.deinit();

    try std.testing.expectEqual(@as(u64, 1001), parsed.value.id);
    try std.testing.expectEqualStrings("alice", parsed.value.username);
    try std.testing.expectEqual(true, parsed.value.is_admin);
}
```

---

## 2. TCP 에코 서버 만들기

`std.Io.net`의 TCP 리스너와 스트림 처리 예제입니다. `zig run main.zig`로 실행한 뒤 다른 터미널에서 `nc 127.0.0.1 9000`으로 접속하세요. 한 연결을 처리하고 종료하며, 받은 바이트를 그대로 돌려줍니다.

```zig
const std = @import("std");

fn handleClient(io: std.Io, stream: std.Io.net.Stream) !void {
    defer stream.close(io);
    var writer = stream.writer(io, &.{});
    var buffer: [1024]u8 = undefined;

    while (true) {
        var buffers = [_][]u8{&buffer};
        const bytes_read = try stream.read(io, &buffers);
        if (bytes_read == 0) break; // 연결 종료
        try writer.interface.writeAll(buffer[0..bytes_read]); // 에코 응답
        try writer.interface.flush();
    }
}

pub fn main(init: std.process.Init) !void {
    const address = try std.Io.net.IpAddress.parse("127.0.0.1", 9000);
    var server = try address.listen(init.io, .{ .reuse_address = true });
    defer server.deinit(init.io);
    const stream = try server.accept(init.io);
    try handleClient(init.io, stream);
}
```

---

## 💡 요약

- `std.json.Stringify.valueAlloc`과 `std.json.parseFromSlice`로 Zig 구조체와 JSON 간의 변환을 수행합니다. 반환된 메모리는 각각 `free`와 `deinit`으로 해제합니다.
- `std.Io.net`의 소켓과 Reader/Writer에는 명시적인 I/O 구현을 전달합니다.
