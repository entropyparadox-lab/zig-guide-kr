---
title: "01. 시작하기 및 툴체인 설정"
description: "Zig 컴파일러 설치부터 Hello World, 기본 빌드 및 테스트 워크플로우까지 단계별로 알아봅니다."
---

# 01. 시작하기 및 툴체인 설정

이 챕터에서는 Zig 툴체인을 설치하고, 첫 번째 프로그램을 작성 및 빌드하며, 내장 테스트 러너를 실행하는 기본적인 개발 워크플로우를 단계별로 안내합니다.

---

## 1. Zig 설치하기 (v0.16.0)

Zig은 외부 의존성이 전혀 없는 단일 바이너리(Single Binary) 형태로 배포됩니다. 복잡한 환경 설정 없이 압축을 풀고 실행 경로(`PATH`)에 추가하기만 하면 즉시 사용할 수 있습니다.

### Linux / macOS
공식 릴리스 아카이브를 다운로드하여 설치합니다:

```bash
# Linux x86_64 예시
curl -LO https://ziglang.org/download/0.16.0/zig-linux-x86_64-0.16.0.tar.xz
tar -xf zig-linux-x86_64-0.16.0.tar.xz
mkdir -p ~/.local/bin
ln -sf $(pwd)/zig-linux-x86_64-0.16.0/zig ~/.local/bin/zig

# 버전 확인
zig version
# 0.16.0
```

### macOS (Homebrew)
```bash
brew install zig
```

### Windows (winget 또는 Scoop)
```powershell
winget install zig.zig
# 또는
scoop install zig
```

---

## 2. Hello, World! 첫 프로그램 작성

새 디렉터리를 만들고 `main.zig` 파일을 작성합니다.

```bash
mkdir hello-zig && cd hello-zig
```

`main.zig`:
```zig
const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello, {s}!\n", .{"World"});
}
```

### 코드 분석
1. `const std = @import("std");`: Zig 표준 라이브러리를 임포트합니다.
2. `pub fn main() !void`: 진입점 함수입니다. `!void`는 이 함수가 에러를 반환할 수 있는 에러 유니온(`Error!void`)임을 의미합니다.
3. `const stdout = std.io.getStdOut().writer();`: 표준 출력 스트림의 `Writer` 인터페이스를 획득합니다.
4. `try stdout.print(...)`: 포맷 문자열을 출력합니다. `try` 키워드는 I/O 작업 중 에러가 발생하면 호출자에게 즉시 에러를 전파(return)합니다.

---

## 3. 실행 및 컴파일

Zig은 소스 코드를 즉시 컴파일하고 실행하는 `run` 명령을 제공합니다:

```bash
zig run main.zig
# 출력: Hello, World!
```

바이너리로 직접 컴파일하려면 `build-exe`를 사용합니다:

```bash
zig build-exe main.zig
./main
```

최적화 모드를 지정하여 릴리스 빌드를 생성할 수 있습니다:
- `-O ReleaseFast`: 안전성 검사를 최소화하고 최고 속도로 최적화
- `-O ReleaseSafe`: 안전성 검사(Safety Checks)를 유지하면서 최적화
- `-O ReleaseSmall`: 바이너리 크기 최소화

```bash
zig build-exe main.zig -O ReleaseFast -fstrip
```

---

## 4. 단위 테스트 (Unit Testing)

Zig은 테스트 프레임워크가 언어 자체에 일급 시민(First-class citizen)으로 내장되어 있습니다. 별도의 테스트 라이브러리를 설치할 필요가 없습니다.

`math_util.zig`:
```zig
const std = @import("std");
const testing = std.testing;

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic addition test" {
    const result = add(2, 3);
    try testing.expectEqual(@as(i32, 5), result);
}

test "negative numbers addition" {
    try testing.expect(add(-1, -1) == -2);
}
```

테스트를 실행합니다:
```bash
zig test math_util.zig
# All 2 tests passed.
```

---

## 💡 요약 및 다음 단계

- Zig은 단일 바이너리로 동작하며 설치와 배포가 매우 간결합니다.
- `zig run`, `zig build-exe`, `zig test`만으로 기본적인 컴파일, 빌드, 테스트를 완결할 수 있습니다.
- 다음 챕터에서는 실제 프로젝트 관리의 핵심인 **[02. 빌드 시스템 완벽 가이드 (build.zig)](/zig-guide-kr/guides/02-build-system/)**를 살펴봅니다.
