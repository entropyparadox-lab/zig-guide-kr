---
title: "10. 크로스 컴파일과 초경량 프로덕션 배포"
description: "크로스 컴파일 타깃 플래그, musl 정적 링크, Docker Scratch 컨테이너를 통한 수 메가바이트 단위 배포 전략."
---

# 10. 크로스 컴파일과 초경량 프로덕션 배포

Zig의 가장 강력한 초능력 중 하나는 **어떤 호스트 OS에서든 모든 주요 운영체제(Linux, macOS, Windows, WASM, FreeBSD 등)와 아키텍처(x86_64, aarch64, riscv64, arm)로 즉시 크로스 컴파일**할 수 있다는 점입니다.

---

## 1. 단일 명령 크로스 컴파일 (`-Dtarget`)

추가 SDK나 툴체인 설치 없이 `zig build` 플래그 하나로 다른 OS용 바이너리를 생성합니다:

```bash
# 1. Linux ARM64 (AWS Graviton, Raspberry Pi) 정적 바이너리 빌드
zig build -Dtarget=aarch64-linux-musl -Doptimize=ReleaseSmall

# 2. Windows x86_64 실행 파일(.exe) 빌드
zig build -Dtarget=x86_64-windows-gnu -Doptimize=ReleaseFast

# 3. macOS Apple Silicon (M1/M2/M3) 빌드
zig build -Dtarget=aarch64-macos -Doptimize=ReleaseFast

# 4. WebAssembly (WASM) 빌드
zig build -Dtarget=wasm32-wasi -Doptimize=ReleaseSmall
```

---

## 2. Docker `scratch` 컨테이너 배포 (바이너리 크기 < 5MB)

`musl` libc로 완전 정적 링크된 바이너리는 OS 라이브러리가 전혀 없는 빈 Docker 이미지(`scratch`)에서 바로 실행됩니다.

`Dockerfile`:
```dockerfile
# 1단계: 빌더
FROM alpine:3.20 AS builder
RUN apk add --no-cache curl tar xz
RUN curl -LO https://ziglang.org/download/0.16.0/zig-linux-x86_64-0.16.0.tar.xz && \
    tar -xf zig-linux-x86_64-0.16.0.tar.xz && \
    mv zig-linux-x86_64-0.16.0 /opt/zig

WORKDIR /app
COPY . .
RUN /opt/zig/zig build -Dtarget=x86_64-linux-musl -Doptimize=ReleaseSmall -fstrip

# 2단계: 초경량 최종 이미지 (단 1~3MB)
FROM scratch
COPY --from=builder /app/zig-out/bin/my-app /my-app
ENTRYPOINT ["/my-app"]
```

---

## 💡 요약

- Zig 컴파일러는 자체적으로 LLVM과 Clang, 수많은 타깃의 libc(musl, glibc, mingw)를 포함하고 있어 완벽한 크로스 컴파일을 보장합니다.
- `scratch` 기반 컨테이너로 패키징하면 공격 표면(Attack Surface)이 극도로 최소화된 초경량 프로덕션 서비스를 운영할 수 있습니다.
