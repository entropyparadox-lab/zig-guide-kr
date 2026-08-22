---
title: "07. 실전 프로젝트: 고성능 CLI 도구 제작"
description: "명령행 인자 파싱, 파일 I/O, 메모리 누수 방어, 에러 핸들링을 종합하여 실제 고성능 단어 빈도 카운터 CLI를 완성합니다."
---

# 07. 실전 프로젝트: 고성능 CLI 도구 제작

지금까지 배운 Allocator 패턴, `build.zig`, 에러 핸들링, 파일 I/O를 종합하여, 대용량 텍스트 파일을 고속으로 읽어 단어 빈도를 집계하는 실전 CLI 도구(`word-counter`)를 단계별로 제작합니다.

---

## 1. 프로젝트 목표 및 설계

- **기능**: 입력 파일 경로를 받아 파일 내 모든 단어의 발생 빈도를 계산하고 상위 N개를 출력
- **아키텍처 요구사항**:
  - `GeneralPurposeAllocator`로 메인 메모리 관리 및 누수 차단
  - `std.StringHashMap(u32)`로 단어 카운팅
  - 버퍼 I/O(`std.io.bufferedReader`)를 통한 고속 파일 읽기
  - 깔끔한 인자 파싱 및 에러 리포팅

---

## 2. 전체 소스 코드 (`src/main.zig`)

```zig
const std = @import("std");

pub fn main() !void {
    // 1. Allocator 초기화 및 메모리 누수 감시
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const check = gpa.deinit();
        if (check == .leak) {
            std.debug.print("Error: memory leak detected in GPA\n", .{});
        }
    }
    const allocator = gpa.allocator();

    // 2. 명령행 인자 파싱
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.skip(); // 실행 바이너리 이름 건너뛰기

    const file_path = args.next() orelse {
        std.debug.print("Usage: word-counter <file-path>\n", .{});
        return error.InvalidArguments;
    };

    // 3. 파일 열기 및 버퍼 리더 설정
    const file = std.fs.cwd().openFile(file_path, .{}) catch |err| {
        std.debug.print("Failed to open file '{s}': {s}\n", .{ file_path, @errorName(err) });
        return err;
    };
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

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
    var line_buf: [4096]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        var tokenizer = std.mem.tokenizeAny(u8, line, " \t\r,.;:\"'!?()[]{}");
        while (tokenizer.next()) |token| {
            if (token.len == 0) continue;

            const gop = try word_counts.getOrPut(token);
            if (gop.found_existing) {
                gop.value_ptr.* += 1;
            } else {
                // 새로운 단어는 영구 보존을 위해 힙에 복사(dupe)
                gop.key_ptr.* = try allocator.dupe(u8, token);
                gop.value_ptr.* = 1;
            }
        }
    }

    // 6. 결과 출력
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n=== Word Frequency Results for '{s}' ===\n", .{file_path});

    var iter = word_counts.iterator();
    var total_unique: usize = 0;
    while (iter.next()) |entry| {
        total_unique += 1;
        try stdout.print(" - {s}: {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    try stdout.print("\nTotal unique words: {d}\n", .{total_unique});
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

출력 결과:
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
