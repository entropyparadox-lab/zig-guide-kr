---
title: "프로젝트 소개 및 가이드"
description: "Zig 한국어 문서 및 실전 가이드 프로젝트의 방향성과 활용법을 소개합니다."
---

# Zig 한국어 가이드 프로젝트 소개

**Zig 한국어 가이드**는 더 견고하고 단순하며 고성능을 지향하는 시스템 프로그래밍 언어 **Zig**를 한국어 개발자 커뮤니티가 쉽고 정확하게 학습할 수 있도록 구축된 오픈소스 문서화 프로젝트입니다.

---

## 🎯 프로젝트 핵심 원칙 (Core Principles)

1. **Two-Track (투트랙) 문서 구조**
   - **Track A (공식 문서 번역)**: `docs.ziglang.org`의 공식 언어 레퍼런스(Language Reference)를 1:1로 충실히 완역하여, 스펙과 레퍼런스가 필요한 엔지니어에게 정확한 표준을 제공합니다.
   - **Track B (Rails-style 실전 가이드)**: Ruby on Rails Guides처럼 입문자부터 실무자까지 스토리라인을 따라가며 실제 동작하는 프로젝트를 만들어보는 실전 핸드북입니다.

2. **개발자 중심의 자연스러운 어휘 (Industry-standard Terminology)**
   - 억지스럽거나 어색한 직역을 지양합니다.
   - 개발 생태계에서 통용되는 영문 전문 용어(예: *Allocator, Comptime, Slice, Defer, Tagged Union, Payload capture, ABI 등*)는 원문 또는 표준 한글 표기로 유지합니다.

3. **코드의 100% 영문 보존 및 자동 검증 (Code Integrity & CI)**
   - 문서 내 모든 소스 코드, 식별자, 주석은 원본 영문을 엄격히 유지합니다.
   - 문서 내 예제 코드는 GitHub Actions CI에서 `zig test` 및 `zig build-exe`로 자동 컴파일 및 테스트되어, 문서가 낡아 코드가 깨지는 현상을 원천 방지합니다.

---

## 🚀 시작하기

- Zig을 처음 접하거나 실무 프로젝트에 적용하고 싶다면 **[Rails-style 실전 가이드](/zig-guide-kr/guides/01-getting-started/)**를 먼저 읽어보세요.
- 특정 문법이나 타입 시스템의 상세 스펙이 필요하다면 **[공식 언어 레퍼런스 (v0.13.0)](/zig-guide-kr/docs/0.13.0/overview/)**를 확인하세요.
- 용어 번역 기준이 궁금하다면 **[개발자 표준 용어집 (Glossary)](/zig-guide-kr/glossary/)**을 참고하세요.
