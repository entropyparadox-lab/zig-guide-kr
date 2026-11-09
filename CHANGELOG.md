# Changelog

## 1.0.1 — unreleased

- Pin validation/CI to stable Zig 0.17.1 and track its official release; retain minimum Zig 0.17.0 and the versioned 0.16.0 archive.
- Replace echo-only package tests and fail-open snippet fallback with real native checks and black-box regressions. Analyze main bodies and evaluate build graphs; execute test assertions.
- Fix current-track examples exposed by strict checks (I/O, threading, JSON, reflection, alignment and build APIs).
- Label the browser playground honestly as a JavaScript simulation, remove fabricated runtime/performance claims and reject edited unsupported input.
- Fix the playground Point union value's inferred enum type; compile and run all six actual component presets with exact output assertions in package tests and PR CI.
- Add a read-only PR quality gate. Existing main Pages auto-deployment remains unchanged.
- Document actual Astro 7 dependencies and the validation scope in README and Korean patch guidance.

Sources: [official download index](https://ziglang.org/download/index.json), [0.17.1 reference](https://ziglang.org/documentation/0.17.1/), [index-linked 0.17.0 release notes](https://ziglang.org/download/0.17.0/release-notes.html). No unverified patch-specific fixes are asserted. No tag or release is created by this change.
