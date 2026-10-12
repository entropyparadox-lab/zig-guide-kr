# AGENTS.md - zig-guide-kr

## 1. 프로젝트 개요 & SSOT
- **프로젝트명**: `zig-guide-kr` (Zig 한국어 공식 레퍼런스 완역 및 실전 가이드)
- **현재 기준 버전 (SSOT)**: **Zig 0.17.0** (공식 안정판)
- **추적 파일**: `tracked_versions.json` (`{"latest_stable": "0.17.0", "master_branch": "0.18.0-dev"}`)
- **문서 프레임워크**: Astro v4 + Starlight + Pagefind
- **타깃 호스트**: GitHub Pages (`https://entropyparadox-lab.github.io/zig-guide-kr/`)

---

## 2. 3트랙 문서 아키텍처 (Three-Track Architecture)
1. **Track A: 공식 언어 레퍼런스 완역 (Language Reference 1:1)**
   - `src/content/docs/docs/0.17.0/`: 0.17.0 기준 정식 완역본 (최신 안정판 기본 트랙)
   - `src/content/docs/docs/0.16.0/`: 0.16.0 레거시 아카이브
   - `src/content/docs/docs/master/`: 0.18.0-dev 데일리 동기화 트랙
2. **Track B: 실전 핸드북 (Guides)**
   - `src/content/docs/guides/`: 01~10 실무 시스템 개발자 중심의 단계별 튜토리얼
   - 할당자 관용구: `init: std.process.Init`, `SafeAllocator`, `BufferFirstAllocator`, `ArrayList = .empty`
3. **Track C: 마이그레이션 & 타 언어 대조**
   - `src/content/docs/releases/`: 버전별 릴리스 노트 (`0170.md`, `0160.md`, `00-migration-matrix.md`)
   - `src/content/docs/from-other-languages/`: C/C++, Rust, Go, Python/TypeScript 대조

---

## 3. 브라우저 WASM 플레이그라운드 규격
- **컴포넌트**: `src/components/ZigPlayground.astro` / `src/content/docs/playground.mdx`
- **런타임**: `wasm32-wasi` 클라이언트 사이드 WebAssembly 런타임 (Zig 0.17.0)
- **표준 프리셋 코드**:
  - `hello`: 기본 포맷팅 및 std.debug.print
  - `memory`: `SafeAllocator` / `init.gpa` 누수 탐지 + `std.ArrayList(u64) = .empty` 관용구
  - `comptime`: Comptime 제네릭 스택
  - `structs`: 구조체, 메서드, Tagged Union
  - `quicksort`: 인플레이스 정렬
- **검증 규칙**: 모든 프리셋 코드는 Zig 0.17.0 문법 및 API 기준 0 에러 유지

---

## 4. 검증 및 배포 파이프라인 (Verification Protocol)
1. **네이티브 스니펫 실컴파일 검증**:
   ```bash
   zig build
   ./zig-out/bin/test-snippets
   ```
   - 문서 내 모든 ` ```zig ` 블록 자동 추출 및 `zig test` / `zig build-obj` 검증 (Total 94 Passed 94 유지)
   - 실행 바이너리가 아닌 템플릿/의사 코드는 반드시 `// pseudo` 주석 명시
2. **정적 사이트 빌드 & 진단 검증**:
   ```bash
   pnpm build
   ```
   - Astro diagnostics: 0 errors, 0 warnings
   - Pagefind 인덱싱: 50+ HTML 파일 정상 인덱싱
3. **배포**:
   - `main` 브랜치 푸시 시 `.github/workflows/deploy.yml` 자동 실행 (Zig 0.17.0 릴리스 바이너리 고정)

---

## 5. 업스트림 버전 감시 (Watchdog)
- **감시 도구**: `./tools/version_watchdog.zig`
- **Cronjob ID**: `4cee59bc9a17` (매일 09:00 KST)
- **동작 규칙**:
  - `https://ziglang.org/download/index.json` 감시
  - 버전 미변경(`status: "no_change"`) 시 `[SILENT]` 반환
  - 0.17.1 등 패치 릴리스 감지 시 자동 PR/이슈 발행 또는 브랜치 알림
