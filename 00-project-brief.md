# Project Brief: Zig Guide KR (한국어 공식 문서 완역 및 실전 가이드)

- **Target Organization**: `entropyparadox-lab`
- **Repository**: `zig-guide-kr`
- **Hosted URL**: `https://entropyparadox-lab.github.io/zig-guide-kr/`
- **SSG Framework**: Astro Starlight + TypeScript + Tailwind/Pretendard CSS
- **Search Engine**: Pagefind Full-text Search (내장)
- **CI/CD Pipeline**: GitHub Actions (`.github/workflows/deploy.yml`) with automated `zig test` snippet validation.

---

## 🎯 핵심 설계 원칙 (Core Architecture)

### 1. Three-Track (3트랙) 문서 구조
- **타 언어 개발자 트랙 (`/from-other-languages/`)**:
  - C/C++, Rust, Go, Python/TypeScript 개발자를 위해 기존 언어의 멘탈 모델과 Zig 시스템 프로그래밍 패러다임을 1:1로 비교 대조.
- **Track A (공식 언어 레퍼런스 완역, `/docs/0160/`)**:
  - `docs.ziglang.org/0.16.0`의 공식 Language Reference 1:1 완역.
  - 기본 문법, 타입 시스템, 구조체/열거형/유니온, 포인터/슬라이스, Comptime, 에러 처리, 빌드 시스템, 메모리 모델, C ABI, 스레드/아토믹, I/O 스트림 등 총 11개 챕터 구성.
- **Track B (Zig 실전 핸드북, `/guides/`)**:
  - 문제 해결과 실무 개발 흐름 중심의 체계적인 핸드북.
  - 시작하기 ~ 빌드 시스템 ~ 메모리/Allocator 패턴 ~ 에러 안전성 ~ Comptime ~ C FFI ~ 실전 단어 빈도 집계 CLI ~ 동시성/스레드 ~ 웹 네트워킹/JSON ~ 크로스 컴파일/Docker Scratch 배포 등 총 10개 챕터 구성.

### 2. 개발자 실무 어휘 채택 (Glossary SSOT)
- 억지스러운 한글 순화어 배제.
- `Allocator`, `Comptime`, `Slice`, `Defer`, `Tagged Union`, `Payload capture`, `ABI`, `Sentinel-terminated` 등 개발 생태계에서 널리 쓰이는 표준 어휘 및 영문 유지 (`glossary.md`).

### 3. 코드 100% 영문 유지 및 자동 컴파일 검증 (CI Harness)
- 모든 코드 블록, 식별자, 주석, 문자열 리터럴 100% 영문 보존.
- 마크다운 내 49개 Zig 코드 스니펫 전체를 실제 `zig test` 및 `zig build-exe`로 자동 컴파일/검증하는 `scripts/test_snippets.py` 구축 (`49/49 PASS`).
