---
title: "02. 빌드 시스템 완벽 가이드 (build.zig)"
description: "Zig 0.16.0의 모듈 기반 선언적 빌드 시스템, build.zig 작성법, 의존성 패키지 관리(zon)를 마스터합니다."
---

# 02. 빌드 시스템 완벽 가이드 (build.zig)

Make, CMake, Cargo와 같은 별도 DSL이나 툴 대신, Zig은 **빌드 스크립트 자체를 Zig 언어로 작성(`build.zig`)**합니다. 이 챕터에서는 Zig 0.16.0의 모듈(`std.Build.Module`) 기반 빌드 시스템과 패키지 매니저(`build.zig.zon`)를 활용한 의존성 관리법을 알아봅니다.

---

## 1. 프로젝트 초기화 (`zig init`)

Zig은 표준적인 프로젝트 템플릿을 생성하는 `zig init` 명령을 제공합니다:

```bash
mkdir my-app && cd my-app
zig init
```

생성되는 구조:
```text
my-app/
├── build.zig          # 빌드 로직 정의
├── build.zig.zon      # 패키지 매니페스트 및 의존성 선언
└── src/
    ├── main.zig       # 실행 파일 진입점
    └── root.zig       # 라이브러리 루트 진입점 (선택적)
```

---

## 2. `build.zig`의 기본 구조 (v0.16.0 모듈 아키텍처)

Zig 0.16.0에서는 빌드 파이프라인이 **일급 모듈(`Module`)** 중심으로 설계되어 컴파일 타깃, 최적화 모드, 소스 루트를 모듈 단위로 정의합니다.

`build.zig`:
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    // 1. 빌드 타깃 및 최적화 옵션 파싱
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 2. 루트 모듈 생성
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // 3. 실행 파일 컴파일 단계 정의
    const exe = b.addExecutable(.{
        .name = "my-app",
        .root_module = exe_mod,
    });

    // 빌드 결과물을 zig-out/bin에 설치하는 단계 추가
    b.installArtifact(exe);

    // 4. 'zig build run' 명령 단계 정의
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // 5. 'zig build test' 명령 단계 정의
    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const exe_unit_tests = b.addTest(.{
        .root_module = test_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
```

---

## 3. `build.zig.zon`을 통한 외부 패키지 의존성 관리

Zig은 탈중앙화된 Git 및 HTTP tarball 패키지 관리를 기본 지원합니다.

`build.zig.zon`:
```zon
.{
    .name = "my-app",
    .version = "0.1.0",
    .minimum_zig_version = "0.16.0",
    .dependencies = .{
        // 외부 패키지 의존성 선언
    },
    .paths = .{
        "build.zig",
        "build.zig.zon",
        "src",
    },
}
```

### 패키지 추가 명령:
```bash
zig fetch --save git+https://github.com/ziglibs/known-folders.git
```

`build.zig`에서 모듈 임포트 연결:
```zig
// pseudo
const known_folders = b.dependency("known-folders", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("known-folders", known_folders.module("known-folders"));
```

---

## 4. 커스텀 빌드 스텝 추가

```zig
// pseudo
const doc_step = b.step("docs", "Generate HTML documentation");
const install_docs = b.addInstallDirectory(.{
    .source_dir = exe.getEmittedDocs(),
    .install_dir = .prefix,
    .install_subdir = "docs",
});
doc_step.dependOn(&install_docs.step);
```
