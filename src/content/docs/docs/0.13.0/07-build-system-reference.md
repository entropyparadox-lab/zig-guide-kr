---
title: "07. 빌드 시스템 레퍼런스 (v0.13.0)"
description: "Zig 0.13.0 공식 레퍼런스 - std.Build API, CompileStep, 모듈 시스템."
---

# 07. 빌드 시스템 레퍼런스

---

## 1. `std.Build` 핵심 API

`build.zig`에서 사용되는 주요 빌드 단계 객체들입니다:

- `b.addExecutable(...)`: 실행 파일 빌드 스텝 생성
- `b.addStaticLibrary(...)`: 정적 라이브러리(`.a`) 빌드 스텝 생성
- `b.addSharedLibrary(...)`: 동적 라이브러리(`.so`, `.dylib`, `.dll`) 빌드 스텝 생성
- `b.addModule(...)`: 재사용 가능한 Zig 모듈 정의
- `b.installArtifact(...)`: 빌드 결과물을 `zig-out` 디렉토리에 배치

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
