# Zig 한국어 문서 & Rails-style 실전 가이드 (Zig KR)

[![Deploy to GitHub Pages](https://github.com/entropyparadox-lab/zig-guide-kr/actions/workflows/deploy.yml/badge.svg)](https://github.com/entropyparadox-lab/zig-guide-kr/actions/workflows/deploy.yml)
[![Zig Version](https://img.shields.io/badge/Zig-0.13.0-orange.svg)](https://ziglang.org)
[![Zig Version](https://img.shields.io/badge/Zig-0.16.0-orange.svg)](https://ziglang.org)

더 견고하고, 최적화 가능하며, 유지보수하기 쉬운 시스템 프로그래밍 언어 **Zig**의 한국어 공식 언어 레퍼런스(v0.16.0) 완역본 및 실전 한국어 핸드북 & 가이드북입니다.

- 🌐 **공식 배포 사이트**: [https://entropyparadox-lab.github.io/zig-guide-kr/](https://entropyparadox-lab.github.io/zig-guide-kr/)

---

## 🚀 프로젝트 주요 구성 (Three-Track Architecture)

### 📢 릴리스 노트 & 마이그레이션 (`/releases/`)
- **버전별 파괴적 변경 매트릭스 (Migration Cheat-Sheet)**: 0.13 → 0.14 → 0.15 → 0.16 한눈에 보는 API 변환표
- **Zig 0.16.0 릴리스 노트**: 최신 릴리스 상세 변경점 및 표준 라이브러리 가이드
- **과거 릴리스 아카이브**: 0.13, 0.14, 0.15 핵심 변경점

### 🚀 타 언어 사용자를 위한 Zig 가이드 (`/from-other-languages/`)
기존 언어의 멘탈 모델과 Zig의 시스템 프로그래밍 패러다임을 1:1로 비교 대조하는 가이드입니다.
- **C/C++ 개발자를 위한 Zig**: 전처리기 매크로 대안(`comptime`), 수동 메모리 할당자(`std.mem.Allocator`), 미정의 동작(UB) 방어, `@cImport`와 `zig cc`.
- **Rust 개발자를 위한 Zig**: Borrow Checker vs 명시적 메모리/`defer`, `Option`/`Result` vs 옵셔널(`?T`)/에러 유니온(`!T`), `comptime` 제네릭스.
- **Go 개발자를 위한 Zig**: GC 없는 마이크로초 저지연 시스템 제어, 에러 핸들링 패턴, 블록 스코프 `defer` 차이점.
- **Python/TypeScript 개발자를 위한 Zig**: 정적 메모리 모델, null/undefined 안전성, 3줄 만에 초고속 네이티브 C 확장 모듈 제작.

### 📖 Track B: Zig 실전 핸드북 (`/guides/`)
입문부터 실무 시스템 엔지니어링까지 단계별로 따라 하며 완성하는 10개 실무 챕터입니다.

### 📚 Track A: 공식 언어 레퍼런스 완역 (`/docs/0160/`)
`docs.ziglang.org/0.16.0` 공식 Language Reference 1:1 완역 스펙 문서입니다.
4. **04. 에러 처리와 안전성 모델** (에러 세트, `try`/`catch`, `errdefer`, 옵셔널 타입)
5. **05. Comptime 메타프로그래밍의 모든 것** (제네릭 함수, `@typeInfo`, 컴파일타임 최적화)
6. **06. C 언어 상호운용성** (`@cImport`, C FFI, Zig를 C 컴파일러로 활용)
7. **07. 실전 프로젝트: 고성능 CLI 도구 제작** (버퍼 I/O, HashMap 단어 빈도 카운터 완성)
8. **08. 동시성과 멀티스레딩 실전 패턴** (`std.Thread`, Mutex, 원자적 연산)
9. **09. 웹 네트워킹과 JSON 직렬화 실전** (`std.json`, TCP 소켓, HTTP 클라이언트)
10. **10. 크로스 컴파일과 초경량 프로덕션 배포** (타깃별 크로스 빌드, Docker `scratch` < 5MB 배포)

### 📚 Track A: 공식 언어 레퍼런스 완역 (`/docs/0.13.0/`)
`docs.ziglang.org/0.13.0` 공식 Language Reference 1:1 완역 스펙 문서입니다.
- 01. 기본 문법과 타입 시스템
- 02. 제어 흐름 및 함수
- 03. 구조체, 열거형, 유니온
- 04. 포인터, 슬라이스, 메모리 모델
- 05. Comptime 및 제네릭
- 06. 에러 처리 및 defer
- 07. 빌드 시스템 레퍼런스
- 08. 메모리 관리 및 Allocator 레퍼런스
- 09. C ABI 및 인라인 어셈블리
- 10. 스레드 및 아토믹 연산
- 11. I/O 스트림 및 파일 시스템

---

## 🛠 로컬 개발 및 테스트

```bash
# 1. 의존성 설치
pnpm install

# 2. 문서 내 모든 Zig 코드 스니펫 컴파일 검증 (49개 스니펫)
pnpm test

# 3. 로컬 개발 서버 실행
pnpm dev

# 4. 프로덕션 정적 사이트 빌드 (Astro check + Pagefind 검색 인덱싱)
pnpm build
```

---

## 📜 라이선스 및 배포

- 배포처: [EntropyParadox Lab](https://github.com/entropyparadox-lab)
- 라이선스: MIT License
