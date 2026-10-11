---
title: "버전별 파괴적 변경 매트릭스 (Migration Cheat-Sheet)"
description: "Zig 0.13 → 0.14 → 0.15 → 0.16 버전별 핵심 파괴적 변경점과 Before/After 코드 변환표."
---

# 버전별 파괴적 변경 매트릭스 (0.13 ~ 0.17)

Zig은 1.0 릴리스 이전까지 언어의 단순성과 성능 최적화를 위해 매 메이저/마이너 버전마다 파괴적 변경(Breaking Changes)을 단행합니다. 이 문서는 구버전 코드를 최신 버전(0.17.0)으로 마이그레이션할 때 필요한 핵심 변경점과 대응 코드를 1:1로 정리한 치트시트입니다.

---

## 1. 핵심 변경점 한눈에 보기

| 영역 | v0.14 ~ v0.15 | v0.16.0 | **v0.17.0 (최신)** | 핵심 해결책 (Fix) |
|---|---|---|---|---|
| **C 헤더 가져오기** | `@cImport(...)` | `@cImport(...)` | **`b.addTranslateC` 모듈화** | `@cImport` 제거됨. 빌드 스텝에서 번역 후 모듈 주입 |
| **빌드 CLI 인자 전달** | `if (b.args)` | `if (b.args)` | **`run_cmd.addPassthruArgs()`** | `b.args` 필드 접근 제거, passthru 방식으로 통일 |
| **문자열 포맷팅 할당** | `std.fmt.allocPrint` | `std.fmt.allocPrint` | **`allocator.print(...)`** | `mem.Allocator` 멤버 메서드로 단축 |
| **센티널 슬라이스 복제** | `allocator.dupeZ` | `allocator.dupeZ` | **`allocator.dupeSentinel(...)`** | 센티널 값을 명시하는 `dupeSentinel(T, slice, 0)` 사용 |
| **배열 초기화** | `[1]T{0} ** N` | `[1]T{0} ** N` | **`@splat(0)`** | 배열 곱셈 문법 `**` 삭제됨. `@splat` 사용 |
| **구조체 타입 리플렉션** | `info.fields` 단일 배열 | `info.fields` 단일 배열 | **Struct-Of-Arrays (`field_names` 등)** | `field_names`, `field_types`, `field_attrs` 분리 |
| **디버그 메모리 할당자** | `GeneralPurposeAllocator` | `DebugAllocator` | **`SafeAllocator` / `smp_allocator`** | 스레드 안전성과 카나리가 강화된 할당자 사용 |

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
