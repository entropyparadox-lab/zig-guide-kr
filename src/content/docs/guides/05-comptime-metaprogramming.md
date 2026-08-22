---
title: "05. Comptime 메타프로그래밍의 모든 것"
description: "별도 매크로 언어 없이 Zig 언어 자체로 컴파일 타임에 코드를 생성하고 제네릭스를 구현하는 법을 알아봅니다."
---

# 05. Comptime 메타프로그래밍의 모든 것

C++의 복잡한 템플릿 메타프로그래밍이나 Rust의 매크로 시스템 대신, Zig은 **동일한 Zig 문법으로 컴파일 시점에 코드를 실행하는 `comptime`** 메커니즘을 제공합니다.

---

## 1. 제네릭스 (Generics as Functions)

Zig에는 `<T>` 같은 특별한 제네릭 문법이 없습니다. 대신 **타입을 인자로 받아 새로운 타입을 반환하는 일반 함수**를 작성합니다.

```zig
const std = @import("std");

// 제네릭 Stack 구조체 생성기
fn Stack(comptime T: type) type {
    return struct {
        items: []T,
        len: usize,
        allocator: std.mem.Allocator,

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator, capacity: usize) !Self {
            const memory = try allocator.alloc(T, capacity);
            return Self{
                .items = memory,
                .len = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        pub fn push(self: *Self, value: T) !void {
            if (self.len >= self.items.len) return error.StackOverflow;
            self.items[self.len] = value;
            self.len += 1;
        }

        pub fn pop(self: *Self) ?T {
            if (self.len == 0) return null;
            self.len -= 1;
            return self.items[self.len];
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Stack(i32) 타입 인스턴스화
    var int_stack = try Stack(i32).init(allocator, 10);
    defer int_stack.deinit();

    try int_stack.push(42);
    try int_stack.push(100);

    std.debug.print("Popped: {?d}\n", .{int_stack.pop()});
    std.debug.print("Popped: {?d}\n", .{int_stack.pop()});
}
```

---

## 2. 컴파일 타임 코드 실행 및 최적화

컴파일 시점에 복잡한 계산이나 룩업 테이블(Lookup Table)을 생성해 바이너리에 상수로 포함할 수 있습니다.

```zig
const std = @import("std");

// 컴파일 타임 팩토리얼 계산
fn comptimeFactorial(comptime n: u64) u64 {
    var result: u64 = 1;
    var i: u64 = 1;
    while (i <= n) : (i += 1) {
        result *= i;
    }
    return result;
}

pub fn main() void {
    // 런타임 연산 없이 컴파일 시점에 상수 3628800으로 치환됨
    const fact10 = comptime comptimeFactorial(10);
    std.debug.print("10! = {d}\n", .{fact10});
}
```

---

## 3. 타입 인트로스펙션 (`@typeInfo`)

Zig의 컴파일 타임 리플렉션을 사용하면 구조체의 모든 필드를 순회하거나 직렬화(JSON, 바이너리) 코드를 자동 생성할 수 있습니다.

```zig
const std = @import("std");

fn printStructFields(comptime T: type) void {
    const info = @typeInfo(T);
    switch (info) {
        .@"struct" => |s| {
            std.debug.print("Struct '{s}' has {d} fields:\n", .{ @typeName(T), s.fields.len });
            inline for (s.fields) |field| {
                std.debug.print(" - {s}: {s}\n", .{ field.name, @typeName(field.type) });
            }
        },
        else => @compileError("Expected a struct type"),
    }
}

const Point = struct {
    x: f32,
    y: f32,
    name: []const u8,
};

pub fn main() void {
    printStructFields(Point);
}
```

---

## 💡 요약

- Zig의 제네릭은 `fn (comptime T: type) type` 형태로 완벽히 투명합니다.
- `inline for`와 `@typeInfo`를 사용하면 타입 안전한 고성능 직렬화, ORM 매핑, 로깅 엔진을 런타임 오버헤드 없이 작성할 수 있습니다.
