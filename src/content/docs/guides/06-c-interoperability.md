---
title: "06. C 언어 상호운용성 (C FFI & C 컴파일러)"
description: "C 헤더(@cImport) 직접 임포트, C 라이브러리 링크, Zig 컴파일러를 C/C++ 툴체인으로 활용하는 법을 설명합니다."
---

# 06. C 언어 상호운용성 (C FFI & C 컴파일러)

Zig은 역사상 C 언어와 가장 매끄럽게 상호운용되는 언어입니다. 별도의 바인딩 생성기(bindgen)나 복잡한 글루 코드 없이 **C 헤더 파일(`.h`)을 직접 임포트**할 수 있으며, 내장된 Clang 툴체인 덕분에 **Zig 컴파일러 자체를 완벽한 C/C++ 크로스 컴파일러로 사용**할 수 있습니다.

---

## 1. C 헤더 직접 임포트 (`@cImport`)

`@cImport`와 `@cInclude`를 사용하면 C 표준 라이브러리나 외부 C 헤더를 즉시 Zig 타입으로 변환하여 사용합니다.

```zig
const std = @import("std");

// C 표준 헤더 임포트
const c = @cImport({
    @cInclude("stdlib.h");
    @cInclude("stdio.h");
    @cInclude("string.h");
});

pub fn main() void {
    const message = "Hello from C FFI!\n";
    _ = c.printf("%s", message.ptr);

    // C malloc / free 직접 호출
    const ptr = c.malloc(128);
    defer c.free(ptr);

    if (ptr != null) {
        _ = c.strcpy(@ptrCast(ptr), "Zig handles C effortlessly");
        _ = c.puts(@ptrCast(ptr));
    }
}
```

---

## 2. C 라이브러리 링크와 크로스 컴파일

시스템 라이브러리(libc)를 링크하는 명령:

```bash
# libc를 링크하여 실행 파일 컴파일
zig build-exe main.zig -lc
```

### `build.zig`에서 C 소스 파일 직접 컴파일
별도 Makefile이나 CMake 없이 `build.zig`에서 C 파일을 빌드에 포함할 수 있습니다:

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.link_libc = true;

    const exe = b.addExecutable(.{
        .name = "c-hybrid-app",
        .root_module = exe_mod,
    });
    exe.addCSourceFile(.{
        .file = b.path("c_src/fast_math.c"),
        .flags = &[_][]const u8{ "-Wall", "-O3" },
    });
    b.installArtifact(exe);
}
```

---

## 3. Zig 컴파일러를 C/C++ 드롭인 컴파일러로 활용 (`zig cc`)

Zig은 내부에 완전한 Clang/LLVM 툴체인을 내장하고 있어, `gcc`나 `clang` 대신 즉시 드롭인으로 사용할 수 있습니다.

### C 파일 컴파일:
```bash
zig cc -O3 -o fast_program fast_program.c
```

### 크로스 컴파일 (Linux에서 Windows 64비트 바이너리 생성):
```bash
zig cc -target x86_64-windows-gnu -o app.exe main.c
```

### 크로스 컴파일 (macOS ARM64 타깃 생성):
```bash
zig cc -target aarch64-macos -o app_mac main.c
```
