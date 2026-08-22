# Zig 한국어 문서 & Rails-style 실전 가이드 (Zig KR)

[![Deploy to GitHub Pages](https://github.com/entropyparadox-lab/zig-guide-kr/actions/workflows/deploy.yml/badge.svg)](https://github.com/entropyparadox-lab/zig-guide-kr/actions/workflows/deploy.yml)
[![Zig Version](https://img.shields.io/badge/Zig-0.13.0-orange.svg)](https://ziglang.org)
[![Astro Starlight](https://img.shields.io/badge/SSG-Astro%20Starlight-purple.svg)](https://starlight.astro.build)

더 견고하고, 최적화 가능하며, 유지보수하기 쉬운 시스템 프로그래밍 언어 **Zig**의 한국어 공식 언어 레퍼런스(v0.13.0) 완역본 및 Ruby on Rails Guides 스타일의 실전 한국어 가이드북입니다.

🌐 **웹사이트**: [https://entropyparadox-lab.github.io/zig-guide-kr/](https://entropyparadox-lab.github.io/zig-guide-kr/)

---

## 🚀 프로젝트 주요 구성 (Two-Track Architecture)

### 📖 Track B: Rails-style 실전 가이드 (`/guides/`)
입문자부터 실무 시스템 엔지니어까지 단계별로 따라 하며 동작하는 프로젝트를 완성하는 직관적인 핸드북입니다.
1. **01. 시작하기 및 툴체인 설정** (Hello World, 단일 바이너리 설치, 내장 테스트 러너)
2. **02. 빌드 시스템 완벽 가이드** (`build.zig` 구조, `build.zig.zon` 패키지 매니저)
3. **03. 메모리 관리와 Allocator 실전 패턴** (GPA, Arena, FixedBuffer, PageAllocator)
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
