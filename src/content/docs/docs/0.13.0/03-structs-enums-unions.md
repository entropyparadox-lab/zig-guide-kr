---
title: "03. 구조체, 열거형, 유니온 (v0.13.0)"
description: "Zig 0.13.0 공식 레퍼런스 - struct, enum, union(enum)(Tagged Union) 및 메서드 정의."
---

# 03. 구조체, 열거형, 유니온

---

## 1. 구조체 (Structs)

구조체는 여러 타입의 필드를 묶는 사용자 정의 복합 타입입니다.

```zig
const std = @import("std");

const User = struct {
    id: u64,
    name: []const u8,
    is_active: bool = true, // 기본값 설정 가능

    // 메서드 선언
    pub fn printInfo(self: User) void {
        std.debug.print("User {d}: {s} (active: {})\n", .{ self.id, self.name, self.is_active });
    }
};
```

---

## 2. 열거형 (Enums)

이름 붙은 정수 상수들의 집합입니다.

```zig
const HttpMethod = enum {
    GET,
    POST,
    PUT,
    DELETE,

    pub fn isRead(self: HttpMethod) bool {
        return self == .GET;
    }
};

const current_method = HttpMethod.GET;
```

---

## 3. 태그드 유니온 (Tagged Unions)

`union(enum)` 구문은 현재 어떤 타입이 유효한지 enum 태그로 명시하여, 런타임 타입 안전성을 100% 보장합니다.

```zig
const std = @import("std");

const Payload = union(enum) {
    text: []const u8,
    int_value: i64,
    float_value: f64,
    none,
};

fn handlePayload(p: Payload) void {
    switch (p) {
        .text => |t| std.debug.print("Text: {s}\n", .{t}),
        .int_value => |i| std.debug.print("Int: {d}\n", .{i}),
        .float_value => |f| std.debug.print("Float: {d}\n", .{f}),
        .none => std.debug.print("Empty\n", .{}),
    }
}
```
