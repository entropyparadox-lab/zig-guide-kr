const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 1. Version Watchdog 바이너리
    const watchdog_exe = b.addExecutable(.{
        .name = "version-watchdog",
        .root_source_file = b.path("tools/version_watchdog.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(watchdog_exe);

    // 2. Test Snippets 검증기 바이너리
    const test_snippets_exe = b.addExecutable(.{
        .name = "test-snippets",
        .root_source_file = b.path("tools/test_snippets.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(test_snippets_exe);

    // zig build watchdog 실행 스텝
    const run_watchdog = b.addRunArtifact(watchdog_exe);
    if (b.args) |args| {
        run_watchdog.addArgs(args);
    }
    const watchdog_step = b.step("watchdog", "Run the Zig upstream version watchdog");
    watchdog_step.dependOn(&run_watchdog.step);

    // zig build test-snippets 실행 스텝
    const run_test_snippets = b.addRunArtifact(test_snippets_exe);
    const test_snippets_step = b.step("test-snippets", "Run the code snippet validation harness");
    test_snippets_step.dependOn(&run_test_snippets.step);
}
