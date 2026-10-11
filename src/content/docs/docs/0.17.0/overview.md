---
title: "Zig 공식 언어 레퍼런스 (v0.17.0) 개요"
description: "Zig 0.17.0 공식 문서(Language Reference)의 한국어 1:1 완역본 개요 및 목차입니다."
---

# Zig 공식 언어 레퍼런스 (v0.17.0)

이 문서는 Zig 공식 릴리스 `0.17.0`의 **Language Reference**를 원문에 충실하게 1:1 한국어로 번역한 기술 스펙 문서입니다.

---

## 📖 공식 레퍼런스 목차

1. **[01. 기본 문법과 타입 시스템](/zig-guide-kr/docs/0170/01-basics-and-types/)**
   - 주석, 식별자, 기본 원시 타입(정수, 부동소수점, 불리언), 배열 및 벡터
2. **[02. 제어 흐름 및 함수](/zig-guide-kr/docs/0170/02-control-flow-and-functions/)**
   - `if`, `while`, `for`, `switch`, 함수 선언, 파라미터 전달 규칙
3. **[03. 구조체, 열거형, 유니온](/zig-guide-kr/docs/0170/03-structs-enums-unions/)**
   - `struct`, `enum`, `union(enum)`(Tagged Union), 튜플, 익명 구조체
4. **[04. 포인터, 슬라이스, 메모리 모델](/zig-guide-kr/docs/0170/04-pointers-and-slices/)**
   - 단일 포인터(`*T`), 다중 포인터(`[*]T`), 슬라이스(`[]T`), 센티널 종단 포인터(`[*:0]T`), 얼라인먼트
5. **[05. Comptime 및 제네릭](/zig-guide-kr/docs/0170/05-comptime-and-generics/)**
   - `comptime` 키워드, 타입 함수, `@typeInfo` SoA 리플렉션, 인라인 루프(`inline for`), 컴파일타임 어설션
6. **[06. 에러 처리 및 defer](/zig-guide-kr/docs/0170/06-errors-and-defer/)**
   - 에러 세트, 에러 유니온(`!T`), `try`, `catch`, `defer`, `errdefer`, 스택 트레이스
7. **[07. 빌드 시스템 레퍼런스](/zig-guide-kr/docs/0170/07-build-system-reference/)**
   - `std.Build` API 레퍼런스, Maker/Configurer 아키텍처, `addPassthruArgs`, 컴파일 타깃, 모듈 시스템
8. **[08. 메모리 및 할당자 레퍼런스](/zig-guide-kr/docs/0170/08-memory-and-allocators-ref/)**
   - `mem.Allocator`, `init.gpa`, `SafeAllocator`, `BufferFirstAllocator`, `smp_allocator`
9. **[09. C ABI 상호운용성 및 어셈블리](/zig-guide-kr/docs/0170/09-c-abi-and-assembly/)**
   - `b.addTranslateC` 모듈화, `export fn`, `extern struct`, 인라인 어셈블리
10. **[10. 스레드 및 아토믹](/zig-guide-kr/docs/0170/10-threads-and-atomics/)**
    - `std.Thread`, 뮤텍스, 아토믹 연산
11. **[11. I/O 및 스트림](/zig-guide-kr/docs/0170/11-io-and-streams/)**
    - `std.Io` 아키텍처, 파일 읽기/쓰기, 버퍼링 스트림

---

## 📌 번역 및 표기 규칙
- **원문 충실성**: 문법 규칙, 타입 시그니처, 스펙 설명은 원문 구조를 그대로 유지합니다.
- **코드 및 식별자**: 모든 코드 예제, 변수명, 함수명, 키워드는 100% 영문으로 보존됩니다.
- **실전 튜토리얼**: 프로젝트 구축 중심의 학습을 원하시면 **[Zig 실전 핸드북](/zig-guide-kr/guides/01-getting-started/)**을 참조하세요.
