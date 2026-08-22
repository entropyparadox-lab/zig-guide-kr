---
title: "02. 빌드 시스템 완벽 가이드 (build.zig)"
description: "Zig의 선언적 빌드 시스템, build.zig 작성법, 의존성 패키지 관리(zon)를 마스터합니다."
---

# 02. 빌드 시스템 완벽 가이드 (build.zig)

Make, CMake, Cargo와 같은 별도 DSL이나 툴 대신, Zig은 **빌드 스크립트 자체를 Zig 언어로 작성(`build.zig`)**합니다. 이 챕터에서는 `build.zig`의 구조와 패키지 매니저(`build.zig.zon`)를 활용한 의존성 관리법을 알아봅니다.

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

## 2. `build.zig`의 기본 구조 (v0.13.0)

`build.zig`:
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    // 1. 빌드 타깃 및 최적화 옵션 파싱
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 2. 실행 파일 컴파일 단계 정의
    const exe = b.addExecutable(.{
        .name = "my-app",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // 빌드 결과물을 zig-out/bin에 설치하는 단계 추가
    b.installArtifact(exe);

    // 3. 'zig build run' 명령 단계 정의
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // 4. 'zig build test' 명령 단계 정의
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
```

### 주요 빌드 명령
```bash
# 기본 빌드 (zig-out/bin/my-app 생성)
zig build

# 릴리스 모드로 빌드
zig build -Doptimize=ReleaseFast

# 다른 플랫폼으로 크로스 컴파일 (예: Windows x86_64)
zig build -Dtarget=x86_64-windows

# 빌드 및 실행
zig build run

# 전체 테스트 실행
zig build test
```

---

## 3. 패키지 매니저 (`build.zig.zon`)

Zig 0.11+부터 내장된 패키지 매니저는 ZON(Zig Object Notation) 형식을 사용합니다.

`build.zig.zon`:
```zon
.{
    .name = "my-app",
    .version = "0.1.0",
    .minimum_zig_version = "0.13.0",
    .dependencies = .{
        // 외부 패키지 의존성 예시
    },
    .paths = .{
        "build.zig",
        "build.zig.zon",
        "src",
    },
}
```

### 외부 패키지 추가하기
```bash
# GitHub 또는 URL에서 패키지 자동 추가 및 해시 계산
zig fetch --save git+https://github.com/ziglibs/known-folders.git
```

`build.zig`에서 모듈 임포트:
```zig
// pseudo
const known_folders = b.dependency("known-folders", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("known-folders", known_folders.module("known-folders"));
```

---

## 💡 요약

- `build.zig`는 완전한 프로그래밍 언어의 표현력을 가지므로 복잡한 전처리, 코드 생성, C 라이브러리 링크를 안전하고 명확하게 제어할 수 있습니다.
- `build.zig.zon`을 통해 외부 의존성을 SHA-256 무결성 검증과 함께 선언적으로 관리합니다.
