---
title: "07. 실전 프로젝트: 고성능 CLI 도구 제작"
description: "명령행 인자 파싱, 파일 I/O, 메모리 누수 방어, 에러 핸들링을 종합하여 실제 고성능 단어 빈도 카운터 CLI를 완성합니다."
---

# 07. 실전 프로젝트: 고성능 CLI 도구 제작

지금까지 배운 Allocator 패턴, `build.zig`, 에러 핸들링, 파일 I/O를 종합하여, 대용량 텍스트 파일을 고속으로 읽어 단어 빈도를 집계하는 실전 CLI 도구(`word-counter`)를 단계별로 제작합니다.

---

## 1. 프로젝트 목표 및 설계

- **기능**: 입력 파일 경로를 받아 파일 내 모든 단어의 발생 빈도를 계산하고 출력 (해시맵 순서는 보장하지 않음)
- **아키텍처 요구사항**:
  - `std.process.Init.gpa`로 메모리를 할당하고 `defer`로 해제
  - `std.StringHashMap(u32)`로 단어 카운팅
  - `std.Io.File.Reader`로 한 줄씩 읽기 (최대 줄 길이 4096바이트)
  - 깔끔한 인자 파싱 및 에러 리포팅

---

## 2. 전체 소스 코드 (`src/main.zig`)

```zig
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    // 1. 프로세스가 제공하는 할당자와 I/O 구현
    const allocator = init.gpa;
    const io = init.io;

    // 2. 명령행 인자 파싱
    var args = try init.minimal.args.iterateAllocator(allocator);
    defer args.deinit();

    _ = args.skip(); // 실행 바이너리 이름 건너뛰기

    const file_path = args.next() orelse {
        std.debug.print("Usage: word-counter <file-path>\n", .{});
        return error.InvalidArguments;
    };

    // 3. 파일 열기 및 버퍼 리더 설정
    const file = std.Io.Dir.cwd().openFile(io, file_path, .{}) catch |err| {
        std.debug.print("Failed to open file '{s}': {s}\n", .{ file_path, @errorName(err) });
        return err;
    };
    defer file.close(io);

    var read_buffer: [4096]u8 = undefined;
    var file_reader = file.reader(io, &read_buffer);
    const in_stream = &file_reader.interface;

    // 4. 단어 빈도 해시맵 초기화
    var word_counts = std.StringHashMap(u32).init(allocator);
    defer {
        // 해시맵의 키(dupe된 문자열) 모두 해제 후 맵 정리
        var key_iter = word_counts.keyIterator();
        while (key_iter.next()) |key| {
            allocator.free(key.*);
        }
        word_counts.deinit();
    }

    // 5. 한 줄씩 읽으며 공백/구두점 기준 단어 분리
    while (try in_stream.takeDelimiter('\n')) |line| {
        var tokenizer = std.mem.tokenizeAny(u8, line, " \t\r,.;:\"'!?()[]{}");
        while (tokenizer.next()) |token| {
            if (token.len == 0) continue;

            if (word_counts.getPtr(token)) |count| {
                count.* += 1;
            } else {
                // 리더 버퍼는 재사용되므로 키를 복사합니다.
                const owned = try allocator.dupe(u8, token);
                errdefer allocator.free(owned);
                try word_counts.put(owned, 1);
            }
        }
    }

    // 6. 결과 출력
    var write_buffer: [4096]u8 = undefined;
    var file_writer = std.Io.File.stdout().writer(io, &write_buffer);
    const stdout = &file_writer.interface;
    try stdout.print("\n=== Word Frequency Results for '{s}' ===\n", .{file_path});

    var iter = word_counts.iterator();
    var total_unique: usize = 0;
    while (iter.next()) |entry| {
        total_unique += 1;
        try stdout.print(" - {s}: {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    try stdout.print("\nTotal unique words: {d}\n", .{total_unique});
    try stdout.flush();
}
```

---

## 3. 빌드 및 실행 검증

```bash
# 빌드
zig build-exe src/main.zig -O ReleaseFast

# 테스트용 파일 생성 및 실행
echo "Zig is fast. Zig is simple! Zig is modern." > sample.txt
./main sample.txt
```

출력 결과 (단어별 행 순서는 달라질 수 있습니다):
```text
=== Word Frequency Results for 'sample.txt' ===
 - Zig: 3
 - is: 3
 - fast: 1
 - simple: 1
 - modern: 1

Total unique words: 5
```

---

## 💡 요약 및 가이드 완주

- 이제 Zig의 환경 설정, `build.zig`, 메모리 할당자, 에러 처리, Comptime, C FFI 및 실전 CLI까지 전 과정을 습득하셨습니다.
- 더 깊은 언어 스펙과 세부 규칙은 **[공식 언어 레퍼런스 (v0.16.0)](/zig-guide-kr/docs/0.16.0/overview/)**에서 확인하세요!
