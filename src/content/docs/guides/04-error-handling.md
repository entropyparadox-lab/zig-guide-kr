---
title: "04. 에러 처리와 안전성 모델"
description: "Zig의 일급 에러 세트, try/catch, errdefer, 옵셔널 타입과 페이로드 캡처를 깊이 있게 다룹니다."
---

# 04. 에러 처리와 안전성 모델

Zig은 예외(Exception)나 은닉된 에러 코드 대신, **명시적인 에러 세트(Error Sets)**와 **에러 유니온(Error Unions)**을 언어 레벨에서 지원합니다. 제어 흐름이 항상 명확하며 비용이 들지 않는 에러 처리가 가능합니다.

---

## 1. 에러 세트 (Error Sets)

에러 세트는 발생할 수 있는 에러 이름들의 열거형 집합입니다.

```zig
const FileError = error{
    NotFound,
    AccessDenied,
    DiskFull,
};

const NetworkError = error{
    Timeout,
    ConnectionRefused,
};

// 에러 세트 병합 (Error Set Coercion)
const AppError = FileError || NetworkError;
```

---

## 2. 에러 유니온과 `try` / `catch`

타입 앞에 `!`를 붙이면 '에러 또는 성공 값'을 담는 에러 유니온 타입이 됩니다.

```zig
const std = @import("std");

fn parseAge(input: []const u8) !u32 {
    const age = std.fmt.parseInt(u32, input, 10) catch |err| {
        // catch 블록에서 에러 핸들링 또는 기본값 반환
        return err;
    };
    if (age > 150) return error.InvalidAge;
    return age;
}

pub fn main() void {
    const val1 = parseAge("25") catch 0;
    std.debug.print("Age: {d}\n", .{val1});

    // try 키워드는 에러 발생 시 호출자에게 즉시 return err하는 축약 문법입니다.
}
```

---

## 3. `errdefer`를 이용한 자원 롤백

`defer`가 항상 스코프 탈출 시 실행된다면, `errdefer`는 **함수가 에러를 반환하며 종료될 때에만** 실행됩니다. 여러 단계의 자원 할당 중 중간에 실패했을 때 이전 자원을 롤백하는 데 완벽합니다.

```zig
const std = @import("std");

fn createEntity(allocator: std.mem.Allocator) !*Entity {
    const entity = try allocator.create(Entity);
    errdefer allocator.destroy(entity); // 아래 작업이 실패하면 entity 해제

    entity.name = try allocator.dupe(u8, "Player");
    errdefer allocator.free(entity.name); // 아래 작업이 실패하면 name 해제

    entity.buffer = try allocator.alloc(u8, 1024);
    // 모든 할당이 성공하면 errdefer는 실행되지 않고 정상 반환됨!

    return entity;
}

const Entity = struct {
    name: []const u8,
    buffer: []u8,
};
```

---

## 4. 옵셔널 타입 (`?T`)과 페이로드 캡처

Zig의 포인터와 일반 타입은 `null`이 될 수 없습니다. `null`을 허용하려면 `?T`로 선언해야 합니다.

```zig
const std = @import("std");

fn findUser(id: u32) ?[]const u8 {
    if (id == 1) return "Alice";
    if (id == 2) return "Bob";
    return null;
}

pub fn main() void {
    const user = findUser(1);

    // 1. if-else 페이로드 캡처
    if (user) |name| {
        std.debug.print("Found user: {s}\n", .{name});
    } else {
        std.debug.print("User not found\n", .{});
    }

    // 2. orelse 기본값 지정
    const username = findUser(99) orelse "Guest";
    std.debug.print("Username: {s}\n", .{username});
}
```

---

## 💡 요약

- Zig에는 런타임 오버헤드가 있는 예외(throw/catch)가 없으며, 에러는 일반 값처럼 취급됩니다.
- `errdefer`는 트랜잭션 방식의 자원 할당 및 안전한 롤백을 구현하는 핵심 도구입니다.
- 옵셔널(`?T`)과 에러 유니온(`!T`)을 결합하여 `null`과 에러 상태를 컴파일 시점에 완벽히 검증합니다.
