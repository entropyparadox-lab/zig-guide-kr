---
title: "07. 빌드 시스템 레퍼런스 (v0.16.0)"
description: "Zig 0.16.0 공식 레퍼런스 - std.Build API, CompileStep, 모듈 시스템."
---

# 07. 빌드 시스템 레퍼런스

---

## 1. `std.Build` 핵심 API (v0.16.0+)

Zig 0.16.0에서는 컴파일 대상이 모듈(`Module`) 기반으로 일원화되었습니다. 실행 파일이나 라이브러리는 `createModule`로 생성된 모듈을 전달받아 빌드됩니다:

- `b.createModule(...)`: 루트 소스 파일, 타깃, 최적화 레벨을 묶은 비공개 모듈 생성
- `b.addExecutable(.{ .name = "...", .root_module = mod })`: 실행 파일 빌드 스텝 생성
- `b.addStaticLibrary(.{ .name = "...", .root_module = mod })`: 정적 라이브러리(`.a`) 빌드 스텝 생성
- `b.addSharedLibrary(.{ .name = "...", .root_module = mod })`: 동적 라이브러리(`.so`, `.dylib`, `.dll`) 빌드 스텝 생성
- `b.addModule(...)`: 타 패키지에서 임포트 가능한 공개 모듈 정의
- `b.installArtifact(...)`: 빌드 결과물을 `zig-out` 디렉토리에 배치

---

## 2. 표준 `build.zig` 템플릿 (v0.16.0)

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 1. 루트 모듈 생성
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // 2. 실행 파일 생성
    const exe = b.addExecutable(.{
        .name = "my_app",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    // 3. run 스텝 연결
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
```

---

## 2. 크로스 컴파일 타깃 지정

```zig
// pseudo
const target = b.standardTargetOptions(.{
    .default_target = .{
        .cpu_arch = .x86_64,
        .os_tag = .linux,
        .abi = .gnu,
    },
});
```
