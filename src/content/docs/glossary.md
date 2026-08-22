---
title: "개발자 표준 용어집 (Glossary)"
description: "Zig 시스템 프로그래밍에서 사용되는 표준 용어 및 한글 표기 기준입니다."
---

# Zig 개발자 표준 용어집 (Glossary)

이 용어집은 Zig 한국어 문서 및 튜토리얼 전반에서 일관되게 사용되는 번역 기준입니다. 무리한 한글화 대신 국내 개발자들이 가장 직관적으로 이해할 수 있는 업계 표준 어휘를 채택합니다.

---

## 📌 핵심 용어 대조표

| 영문 원문 | 한국어 권장 표기 / 번역 | 설명 및 용례 |
|---|---|---|
| **Allocator** | 할당자 / Allocator | 메모리 할당/해제를 담당하는 인터페이스 (`std.mem.Allocator`). 기술적 맥락에서는 '할당자' 또는 영문 유지. |
| **Comptime** | Comptime / 컴파일 타임 | Zig의 핵심 기능으로 컴파일 시점에 코드를 실행하고 타입을 계산하는 기능. 고유명사로 `comptime` 그대로 표기. |
| **Slice** | 슬라이스 (Slice) | 포인터와 길이를 묶은 연속된 메모리 뷰 (`[]T`, `[]const u8`). |
| **Tagged Union** | 태그드 유니온 / 태그 있는 공용체 | enum 태그와 함께 현재 활성화된 필드 타입을 안전하게 보장하는 공용체. |
| **Error Union** | 에러 유니온 | 에러 세트와 정상 반환 타입을 합친 타입 (`!T` 또는 `ErrorType!T`). |
| **Error Set** | 에러 세트 | 발생 가능한 에러들의 집합 (`error{OutOfMemory, FileNotFound}`). |
| **Defer / Errdefer** | Defer / Errdefer | 스코프를 벗어날 때 실행을 보장(defer)하거나, 에러 발생 시에만 실행(errdefer)하는 예약어. |
| **Payload Capture** | 페이로드 캡처 | `if (optional_val) |val|` 또는 `for (items) |item|` 형태로 내부 값을 바인딩하는 문법. |
| **Optional Type** | 옵셔널 타입 | `null`이 될 수 있는 타입 (`?T`). |
| **Sentinel-terminated** | 센티널 종단 | 특정 값(예: C 문자열의 `\0`)으로 끝나는 포인터나 슬라이스 (`[*:0]const u8`). |
| **Undefined** | undefined / 정의되지 않은 값 | 초기화되지 않은 메모리 상태를 명시적으로 나타내는 키워드. |
| **Unreachable** | unreachable / 도달 불가능 | 논리적으로 실행될 수 없는 코드 경로임을 컴파일러에 알리는 키워드. (Debug 모드에선 panic) |
| **Panic** | 패닉 (Panic) | 프로그램이 복구할 수 없는 치명적 에러 상태에 빠져 즉시 비정상 종료되는 것. |
| **Build Runner** | 빌드 러너 | `build.zig` 스크립트를 해석하고 컴파일 파이프라인을 실행하는 Zig 내부 엔진. |
| **Target** | 타깃 (Target) | 아키텍처, OS, ABI를 조합한 컴파일 대상 환경 (예: `x86_64-linux-gnu`, `aarch64-macos`). |
| **C ABI / C FFI** | C ABI / C FFI | C 언어와의 바이너리 인터페이스 및 외부 함수 인터페이스 상호운용성. |
| **Generics** | 제네릭 (Generics) | Zig에서는 별도 제네릭 문법 없이 `fn (comptime T: type) type` 형태로 타입을 반환하는 함수로 구현. |
| **Inline Assembly** | 인라인 어셈블리 | Zig 코드 내에서 직접 어셈블리 명령어를 작성하는 문법 (`asm volatile (...)`). |

---

## 💡 번역 및 스타일 원칙

1. **식별자 및 코드 보존**: 함수명, 변수명, 키워드, 타입명(`u8`, `usize`, `std.ArrayList` 등)은 코드 블록과 인라인 코드(` `) 모두에서 영문 그대로 표기합니다.
2. **외래어 표기 통일**: '인터페이스', '모듈', '패키지', '바이트', '버퍼' 등 널리 쓰이는 표준 외래어를 사용합니다.
3. **간결한 서술체**: 군더더기 없는 설명과 개발 실무에서 바로 쓸 수 있는 명확한 인과관계 표현을 사용합니다.
