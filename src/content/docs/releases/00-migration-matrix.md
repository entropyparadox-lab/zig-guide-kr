---
title: "버전별 파괴적 변경 매트릭스 (Migration Cheat-Sheet)"
description: "Zig 0.13 → 0.14 → 0.15 → 0.16 버전별 핵심 파괴적 변경점과 Before/After 코드 변환표."
---

# 버전별 파괴적 변경 매트릭스 (0.13 ~ 0.16)

Zig은 1.0 릴리스 이전까지 언어의 단순성과 성능 최적화를 위해 매 메이저/마이너 버전마다 파괴적 변경(Breaking Changes)을 단행합니다. 이 문서는 구버전 코드를 최신 버전으로 마이그레이션할 때 필요한 핵심 변경점과 대응 코드를 1:1로 정리한 치트시트입니다.

---

## 1. 핵심 변경점 한눈에 보기

| 영역 | v0.13.0 | v0.14.0 / v0.15.0 | **v0.16.0 (최신)** | 핵심 해결책 (Fix) |
|---|---|---|---|---|
| **빌드 실행파일 선언** | `b.addExecutable(.{ .root_source_file = ... })` | `b.addExecutable(.{ .root_module = ... })` 과도기 | **`b.addExecutable(.{ .root_module = b.createModule(...) })`** | `createModule`로 컴파일 옵션과 소스를 모듈로 묶어 전달 |
| **디버그 메모리 할당자** | `std.heap.GeneralPurposeAllocator` | `std.heap.GeneralPurposeAllocator` | **`std.heap.DebugAllocator`** | 디버그/누수 감지는 `DebugAllocator`, 릴리스는 `SmpAllocator` |
| **C 호출 규약 태그** | `callconv(.C)` | `callconv(.C)` / `callconv(.c)` | **`callconv(.c)` (소문자)** | `callconv(.c)` 소문자 enum 태그 사용 |
| **HTTP 클라이언트** | `std.http.Client{ .allocator = gpa }` | `std.http.Client` I/O 분리 시작 | **`std.http.Client{ .allocator = alloc, .io = io }`** | `std.Io` 인스턴스를 명시적으로 주입 |
| **표준 출력 포맷팅** | `std.io.getStdOut().writer()` | `std.io` 리팩토링 | **`std.debug.print` / `std.fs.File.writer()`** | 스트림과 디버그 출력의 용도 분리 |

---

## 2. Before & After 마이그레이션 레시피

### 2.1. `build.zig` 실행 파일 및 테스트 생성

#### ❌ Before (0.13.0 이전):
```zig
// ignore
// 0.13.0
const exe = b.addExecutable(.{
    .name = "app",
    .root_source_file = b.path("src/main.zig"),
    .target = target,
    .optimize = optimize,
});
```

#### ✅ After (0.16.0 최신):
```zig
// pseudo
// 0.16.0
const exe_mod = b.createModule(.{
    .root_source_file = b.path("src/main.zig"),
    .target = target,
    .optimize = optimize,
});
const exe = b.addExecutable(.{
    .name = "app",
    .root_module = exe_mod,
});
```

---

### 2.2. 디버그 메모리 할당 및 누수 탐지 (`main.zig`)

#### ❌ Before (0.13.0 이전):
```zig
// ignore
// 0.13.0
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
defer _ = gpa.deinit();
const allocator = gpa.allocator();
```

#### ✅ After (0.16.0 최신):
```zig
// 0.16.0
const std = @import("std");

test "debug allocator after" {
    var dbg = std.heap.DebugAllocator(.{}){};
    defer _ = dbg.deinit();
    const allocator = dbg.allocator();
    _ = allocator;
}
```

---

### 2.3. C FFI 함수 내보내기

#### ❌ Before (0.13.0 이전):
```zig
// ignore
// 0.13.0
export fn add(a: i32, b: i32) callconv(.C) i32 {
    return a + b;
}
```

#### ✅ After (0.16.0 최신):
```zig
// 0.16.0
export fn add(a: i32, b: i32) callconv(.c) i32 {
    return a + b;
}
```
