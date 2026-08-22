---
title: "Rust 개발자를 위한 Zig 가이드"
description: "Borrow Checker vs 수동 메모리/defer, Result/Option vs Error Union, proc-macro vs comptime 비교."
---

# Rust 개발자를 위한 Zig 가이드

Rust와 Zig은 모두 **안전하고 현대적인 시스템 프로그래밍**을 지향하지만, 그 철학과 접근 방식에서 뚜렷한 대조를 이룹니다.

- **Rust의 철학**: 정교한 타입 시스템과 컴파일러(Borrow Checker, Lifetimes)를 통해 컴파일 타임에 모든 메모리 안전성을 증명.
- **Zig의 철학**: 언어의 복잡성을 극도로 단순하게 유지하며(No hidden control flow, No macro DSL), 명시적인 `Allocator`와 `defer`/`errdefer`를 통해 개발자가 메모리를 직관적으로 통제.

---

## 📌 핵심 멘탈 모델 매핑

| Rust 개념 | Zig 대응 개념 | 비교 및 차이점 |
|---|---|---|
| `Borrow Checker` & Lifetimes | `std.mem.Allocator` + `defer` | 수명 어노테이션(`'a`) 없음. 할당과 해제를 명시적으로 제어 |
| `Option<T>` (`Some`/`None`) | 옵셔널 타입 `?T` (`null`) | 언어 내장 프리미티브. `orelse` 또는 `if (opt) \|val\|`로 언래핑 |
| `Result<T, E>` | 에러 유니온 `!T` (`error.X!T`) | 정수 기반 경량 에러. `try` 및 `catch` 키워드로 전파 |
| `macro_rules!` & Proc Macro | `comptime` 함수 & `@typeInfo` | 별도 매크로 문법 없이 일반 Zig 코드로 컴파일타임 코드 생성 |
| `trait` & `impl Trait` | 구조체 필드 함수 포인터 / `comptime` 인터페이스 | 가상 테이블(vtable)을 명시적 구조체로 표현하거나 제네릭 함수로 처리 |
| `Cargo.toml` & `build.rs` | `build.zig.zon` & `build.zig` | 선언적 매니페스트와 프로그래밍 가능한 Zig 빌드 스크립트 |
| `unsafe` 블록 | 포인터 연산 및 `[*]T` | `unsafe` 키워드 구분이 없으며, 릴리스 모드(`ReleaseFast` vs `ReleaseSafe`)로 안전성 제어 |

---

## 1. `Option<T>` vs 옵셔널 (`?T`)

### Rust 코드
```rust
fn find_user(id: u32) -> Option<&'static str> {
    if id == 1 { Some("Alice") } else { None }
}
```

### Zig 코드
```zig
const std = @import("std");

fn findUser(id: u32) ?[]const u8 {
    if (id == 1) return "Alice";
    return null;
}

test "optional unwrapping vs rust option" {
    const user = findUser(1);
    const name = user orelse "Guest";
    try std.testing.expectEqualStrings("Alice", name);
}
```

---

## 2. `Result<T, E>` vs 에러 유니온 (`!T`)

Rust의 `?` 연산자와 `unwrap_or`는 Zig의 `try` 및 `catch`와 정확히 일치합니다.

```zig
const std = @import("std");

fn parseNumber(str: []const u8) !u32 {
    // Rust의 str.parse::<u32>()? 에 대응
    const num = try std.fmt.parseInt(u32, str, 10);
    return num * 2;
}

test "error union vs rust result" {
    const res = try parseNumber("21");
    try std.testing.expectEqual(@as(u32, 42), res);

    // catch로 기본값 폴백 (Rust의 unwrap_or(0))
    const fallback = parseNumber("invalid") catch 0;
    try std.testing.expectEqual(@as(u32, 0), fallback);
}
```

---

## 3. `comptime` 제네릭 vs Rust Generics / Macros

Rust에서는 제네릭을 위해 `<T>` 문법을 쓰고 컴파일타임 코드 생성을 위해 별도의 프로시저 매크로(Proc Macro) 크레이트를 구성해야 하지만, Zig은 일반 함수로 제네릭 타입을 생성합니다.

```zig
const std = @import("std");

// Rust의 struct Wrapper<T> { value: T } 에 대응
fn Wrapper(comptime T: type) type {
    return struct {
        value: T,

        pub fn get(self: @This()) T {
            return self.value;
        }
    };
}

test "comptime generics vs rust struct generics" {
    const IntWrapper = Wrapper(i32);
    const w = IntWrapper{ .value = 42 };
    try std.testing.expectEqual(@as(i32, 42), w.get());
}
```

---

## 💡 Rust 개발자를 위한 팁

1. **복잡한 수명 주기가 필요할 때**: Rust에서 라이프타임(`'a`)으로 고통받는 트리/그래프 구조나 임시 AST는 Zig의 `std.heap.ArenaAllocator`를 사용하면 단 1줄(`defer arena.deinit()`)로 깔끔하게 해결됩니다.
2. **C 상호운용성**: `bindgen` 빌드 설정 없이 `@cImport`로 C 헤더를 즉시 불러올 수 있어 C 생태계 통합이 압도적으로 빠릅니다.
