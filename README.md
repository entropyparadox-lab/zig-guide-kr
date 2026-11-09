# Zig 한국어 문서 & Rails-style 실전 가이드 (Zig KR)

[![Deploy to GitHub Pages](https://github.com/entropyparadox-lab/zig-guide-kr/actions/workflows/deploy.yml/badge.svg)](https://github.com/entropyparadox-lab/zig-guide-kr/actions/workflows/deploy.yml)
[![Zig Version](https://img.shields.io/badge/Zig-0.17.1-orange.svg)](https://ziglang.org/download/)

**Zig 0.17 계열** 한국어 레퍼런스와 실전 핸드북입니다. 검증 및 CI 기준은 안정판 **Zig 0.17.1**이며 패키지 최소 버전은 0.17.0으로 유지합니다. 사이트는 **Astro 7 + Starlight**로 빌드합니다. 0.16.0 문서는 역사 아카이브로 보존합니다.

- 🌐 **공식 배포 사이트**: [https://entropyparadox-lab.github.io/zig-guide-kr/](https://entropyparadox-lab.github.io/zig-guide-kr/)

---

## 🚀 프로젝트 주요 구성 (Three-Track Architecture)

### 📢 릴리스 노트 & 마이그레이션 (`/releases/`)
- **버전별 파괴적 변경 매트릭스 (Migration Cheat-Sheet)**: 0.13 → 0.14 → 0.15 → 0.16 한눈에 보는 API 변환표
- **Zig 0.17.1 패치 안내**: 공식 다운로드 기준과 검증 범위. 0.17.0 및 0.16.0 릴리스 노트도 보존합니다.
- **과거 릴리스 아카이브**: 0.13, 0.14, 0.15 핵심 변경점

### 🚀 타 언어 사용자를 위한 Zig 가이드 (`/from-other-languages/`)
기존 언어의 멘탈 모델과 Zig의 시스템 프로그래밍 패러다임을 1:1로 비교 대조하는 가이드입니다.
- **C/C++ 개발자를 위한 Zig**: 전처리기 매크로 대안(`comptime`), 명시적 할당자, `addTranslateC`와 `zig cc`.
- **Rust 개발자를 위한 Zig**: Borrow Checker vs 명시적 메모리/`defer`, `Option`/`Result` vs 옵셔널(`?T`)/에러 유니온(`!T`), `comptime` 제네릭스.
- **Go 개발자를 위한 Zig**: GC 없는 마이크로초 저지연 시스템 제어, 에러 핸들링 패턴, 블록 스코프 `defer` 차이점.
- **Python/TypeScript 개발자를 위한 Zig**: 정적 메모리 모델, null/undefined 안전성, 3줄 만에 초고속 네이티브 C 확장 모듈 제작.

### 📖 Track B: Zig 실전 핸드북 (`/guides/`)
입문부터 실무 시스템 엔지니어링까지 단계별로 따라 하며 완성하는 10개 실무 챕터입니다.

### 📚 Track A: 공식 언어 레퍼런스 (`/docs/0170/`)
0.17 계열 레퍼런스입니다. 디렉터리명 `docs/0.17.0`은 보존하며 현재 예제는 0.17.1로 검증합니다.
4. **04. 에러 처리와 안전성 모델** (에러 세트, `try`/`catch`, `errdefer`, 옵셔널 타입)
5. **05. Comptime 메타프로그래밍의 모든 것** (제네릭 함수, `@typeInfo`, 컴파일타임 최적화)
6. **06. C 언어 상호운용성** (`addTranslateC`, C FFI, Zig를 C 컴파일러로 활용)
7. **07. 실전 프로젝트: 고성능 CLI 도구 제작** (버퍼 I/O, HashMap 단어 빈도 카운터 완성)
8. **08. 동시성과 멀티스레딩 실전 패턴** (`std.Thread`, Mutex, 원자적 연산)
9. **09. 웹 네트워킹과 JSON 직렬화 실전** (`std.json`, TCP 소켓, HTTP 클라이언트)
10. **10. 크로스 컴파일과 초경량 프로덕션 배포** (타깃별 크로스 빌드, Docker `scratch` < 5MB 배포)

### 📚 레퍼런스 구성 (0.16.0 아카이브 포함)
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

Zig 도구 검증에는 `0.17.1`, Node.js 22, pnpm 10.33.0, Python 3를 사용하세요.

```bash
# 1. 의존성 설치
pnpm install --frozen-lockfile

# 2. 도구 빌드, 검증기 회귀 테스트, 현재 트랙 스니펫 검증
pnpm test

# 3. 로컬 개발 서버 실행
pnpm dev

# 4. 프로덕션 정적 사이트 빌드 (Astro check + Pagefind 검색 인덱싱)
pnpm build
```

---

## 📜 라이선스 및 배포

`pnpm test`는 실제 명령을 실행하며 실패를 숨기지 않습니다. 테스트 블록은 `zig test -lc`, main 예제는 `zig build-exe -lc`, 빌드 예제는 `zig build --help`로 그래프를 평가합니다. 외부 소스까지 빌드하는 검증은 아닙니다. 선언 전용 예제는 Zig의 지연 분석 때문에 모든 본문이 검증되지는 않습니다. `docs/0.16.0` 역사 문서 및 명시된 `// pseudo`, `// ignore`, `// zon` 블록은 제외합니다.

브라우저 플레이그라운드는 **JavaScript 예제 시뮬레이터**이며 실제 Zig 컴파일러/WASM 런타임이 아닙니다. 출력은 준비된 샘플이며 실행 시간·메모리·누수 안전성을 측정하지 않습니다.

PR은 읽기 전용 품질 게이트만 실행합니다. **main 병합 시 기존 Pages 배포가 자동 실행**됩니다. 수동 배포 명령은 필요하지 않습니다.

- 배포처: [EntropyParadox Lab](https://github.com/entropyparadox-lab)
- 라이선스: MIT License
