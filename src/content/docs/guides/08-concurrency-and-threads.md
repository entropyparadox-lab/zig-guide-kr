---
title: "08. 동시성과 멀티스레딩 실전 패턴"
description: "스레드 풀(Thread Pool), 워커 큐, 채널 및 뮤텍스를 활용한 고성능 동시성 프로그래밍을 학습합니다."
---

# 08. 동시성과 멀티스레딩 실전 패턴

시스템 프로그래밍에서 고성능을 달성하기 위한 핵심 요소는 CPU 코어를 최대한 활용하는 멀티스레딩입니다. 이 챕터에서는 `std.Thread`, `std.Io.Mutex`, `std.atomic.Value`를 활용해 작업 결과를 전달하고 공유 상태를 보호하는 방법을 다룹니다.

---

## 1. 스레드 생성과 파라미터 전달

Zig에서 `std.Thread.spawn`은 임의의 개수의 인자를 튜플 형태로 함수에 안전하게 전달합니다.

```zig
const std = @import("std");

fn computeTask(id: usize, input_val: u64, out_result: *u64) void {
    var sum: u64 = 0;
    var i: u64 = 1;
    while (i <= input_val) : (i += 1) {
        sum += i;
    }
    out_result.* = sum + id;
}

test "thread spawn with args" {
    var result: u64 = 0;
    const thread = try std.Thread.spawn(.{}, computeTask, .{ @as(usize, 1), @as(u64, 100), &result });
    thread.join();

    try std.testing.expectEqual(@as(u64, 5051), result);
}
```

---

## 2. Mutex를 활용한 안전한 공유 상태 보호

여러 스레드가 동시에 공유 데이터에 접근할 때 `std.Io.Mutex`로 데이터 레이스를 방지합니다. 락과 해제에는 동일한 `std.Io` 구현을 전달합니다. 이 예제는 일반 스레드의 작업을 끝까지 수행하도록 `lockUncancelable(io)`를 사용합니다.

```zig
const std = @import("std");

const SafeCounter = struct {
    mutex: std.Io.Mutex = .init,
    count: u64 = 0,

    pub fn increment(self: *SafeCounter, io: std.Io) void {
        self.mutex.lockUncancelable(io);
        defer self.mutex.unlock(io);
        self.count += 1;
    }

    pub fn get(self: *SafeCounter, io: std.Io) u64 {
        self.mutex.lockUncancelable(io);
        defer self.mutex.unlock(io);
        return self.count;
    }
};

test "safe counter across threads" {
    var counter = SafeCounter{};

    const worker = struct {
        fn run(c: *SafeCounter, io: std.Io) void {
            var i: usize = 0;
            while (i < 100) : (i += 1) {
                c.increment(io);
            }
        }
    }.run;

    {
        const t1 = try std.Thread.spawn(.{}, worker, .{ &counter, std.testing.io });
        defer t1.join();
        const t2 = try std.Thread.spawn(.{}, worker, .{ &counter, std.testing.io });
        defer t2.join();
    }

    try std.testing.expectEqual(@as(u64, 200), counter.get(std.testing.io));
}
```

---

## 3. 원자적 연산 (Atomic Operations)

간단한 정수 연산의 경우 뮤텍스 락 오버헤드 없이 하드웨어 레벨의 원자적 연산(`std.atomic.Value`)을 사용하는 것이 훨씬 빠릅니다.

```zig
const std = @import("std");

test "atomic counter" {
    var atomic_cnt = std.atomic.Value(u64).init(0);

    _ = atomic_cnt.fetchAdd(10, .monotonic);
    _ = atomic_cnt.fetchAdd(20, .monotonic);

    const val = atomic_cnt.load(.acquire);
    try std.testing.expectEqual(@as(u64, 30), val);
}
```

---

## 💡 요약

- `std.Thread.spawn`은 튜플을 통해 타입 안전하게 인자를 전달합니다.
- `defer mutex.unlock(io)`로 모든 함수 탈출 경로에서 락을 해제합니다.
- 고성능 카운터나 플래그는 `std.atomic.Value`를 활용해 락-프리(Lock-free)로 구현하세요.
