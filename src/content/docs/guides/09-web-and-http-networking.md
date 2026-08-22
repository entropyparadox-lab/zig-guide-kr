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
    var json_str = std.ArrayList(u8).init(allocator);
    defer json_str.deinit();

    try std.json.stringify(user, .{}, json_str.writer());

    // 2. JSON 역직렬화 (Parse)
    const parsed = try std.json.parseFromSlice(
        UserProfile,
        allocator,
        json_str.items,
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

저수준 네트워크 프로그래밍의 기초인 TCP 리스너와 스트림 처리 예제입니다.

```zig
const std = @import("std");

fn handleClient(stream: std.net.Stream) !void {
    defer stream.close();
    var buffer: [1024]u8 = undefined;

    while (true) {
        const bytes_read = try stream.read(&buffer);
        if (bytes_read == 0) break; // 연결 종료
        try stream.writeAll(buffer[0..bytes_read]); // 에코 응답
    }
}

test "tcp server declaration syntax" {
    _ = handleClient;
}
```

---

## 💡 요약

- `std.json.stringify`와 `std.json.parseFromSlice`는 Zig 구조체와 JSON 간의 변환을 타입 안전하고 빠르게 수행합니다.
- `std.net`과 `std.http`를 활용하여 외부 의존성 없는 고성능 마이크로서비스 및 CLI 클라이언트를 제작할 수 있습니다.
