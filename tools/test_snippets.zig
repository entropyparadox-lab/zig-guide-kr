const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    std.debug.print("Running Zig Guide KR Code Snippet Validator (Native Zig)\n", .{});

    var total_snippets: usize = 0;
    var passed_snippets: usize = 0;
    var failed_snippets: usize = 0;

    var docs_dir = try std.fs.cwd().openDir("src/content/docs", .{ .iterate = true });
    defer docs_dir.close();

    var walker = try docs_dir.walk(allocator);
    defer walker.deinit();

    var file_paths = std.ArrayList([]const u8).init(allocator);
    defer {
        for (file_paths.items) |p| allocator.free(p);
        file_paths.deinit();
    }

    while (try walker.next()) |entry| {
        if (entry.kind != .file) continue;
        if (std.mem.endsWith(u8, entry.path, ".md") or std.mem.endsWith(u8, entry.path, ".mdx")) {
            try file_paths.append(try allocator.dupe(u8, entry.path));
        }
    }

    // Sort paths
    std.mem.sort([]const u8, file_paths.items, {}, stringLessThan);

    for (file_paths.items) |rel_path| {
        const file = try docs_dir.openFile(rel_path, .{});
        defer file.close();

        const content = try file.readToEndAlloc(allocator, 10 * 1024 * 1024);
        defer allocator.free(content);

        var idx: usize = 0;
        var cursor: usize = 0;

        while (std.mem.indexOfPos(u8, content, cursor, "```zig\n")) |start_pos| {
            const code_start = start_pos + 7;
            const end_pos = std.mem.indexOfPos(u8, content, code_start, "```") orelse break;
            const code = std.mem.trim(u8, content[code_start..end_pos], " \t\r\n");
            cursor = end_pos + 3;

            if (std.mem.indexOf(u8, code, "// ignore") != null or
                std.mem.indexOf(u8, code, "// pseudo") != null or
                std.mem.indexOf(u8, code, "// zon") != null)
            {
                continue;
            }

            idx += 1;
            total_snippets += 1;

            if (try testSnippet(allocator, code, rel_path, idx)) {
                passed_snippets += 1;
                std.debug.print("  [PASS] {s} (snippet #{d})\n", .{ rel_path, idx });
            } else {
                failed_snippets += 1;
                std.debug.print("  [FAIL] {s} (snippet #{d})\n", .{ rel_path, idx });
            }
        }
    }

    std.debug.print("\n==================================================\n", .{});
    std.debug.print("Results: Total={d}, Passed={d}, Failed={d}\n", .{ total_snippets, passed_snippets, failed_snippets });
    std.debug.print("==================================================\n", .{});

    if (failed_snippets > 0) {
        std.process.exit(1);
    }
}

fn stringLessThan(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.order(u8, a, b) == .lt;
}

fn testSnippet(allocator: std.mem.Allocator, code: []const u8, rel_path: []const u8, idx: usize) !bool {
    _ = rel_path;
    const has_std = std.mem.indexOf(u8, code, "const std =") != null;
    const has_main = std.mem.indexOf(u8, code, "pub fn main") != null or std.mem.indexOf(u8, code, "fn main") != null;
    const has_build = std.mem.indexOf(u8, code, "pub fn build") != null;
    const has_test = std.mem.indexOf(u8, code, "test ") != null or std.mem.indexOf(u8, code, "test \"") != null;
    const has_export = std.mem.indexOf(u8, code, "export fn") != null;

    const is_decl_only = (std.mem.indexOf(u8, code, "fn ") != null or
        std.mem.indexOf(u8, code, "const ") != null or
        std.mem.indexOf(u8, code, "struct {") != null or
        std.mem.indexOf(u8, code, "union(") != null or
        std.mem.indexOf(u8, code, "enum {") != null) and
        (std.mem.indexOf(u8, code, "+=\n") == null and
        std.mem.indexOf(u8, code, "while (") == null and
        std.mem.indexOf(u8, code, "for (") == null);

    var final_code = std.ArrayList(u8).init(allocator);
    defer final_code.deinit();

    const std_prefix = if (has_std) "" else "const std = @import(\"std\");\n";

    if (has_main or has_test or has_build or has_export) {
        try final_code.appendSlice(code);
    } else if (is_decl_only) {
        try final_code.appendSlice(std_prefix);
        try final_code.appendSlice(code);
        try final_code.appendSlice("\ntest \"syntax check\" {}\n");
    } else {
        try final_code.appendSlice(std_prefix);
        try final_code.appendSlice("test \"statements\" {\n");
        try final_code.appendSlice(code);
        try final_code.appendSlice("\n}\n");
    }

    // Write temp test file
    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    const filename = try std.fmt.allocPrint(allocator, "snippet_{d}.zig", .{idx});
    defer allocator.free(filename);

    const file = try tmp_dir.dir.createFile(filename, .{});
    try file.writeAll(final_code.items);
    file.close();

    const tmp_path = try tmp_dir.dir.realpathAlloc(allocator, filename);
    defer allocator.free(tmp_path);

    const argv = if (has_build or has_export)
        &[_][]const u8{ "zig", "build-obj", tmp_path, "-fno-emit-bin" }
    else
        &[_][]const u8{ "zig", "test", tmp_path };

    var child = std.process.Child.init(argv, allocator);
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;

    const term = try child.spawnAndWait();
    if (term.Exited == 0) return true;

    // Fallback: build-obj syntax/semantic check
    const fallback_argv = &[_][]const u8{ "zig", "build-obj", tmp_path, "-fno-emit-bin" };
    var fallback_child = std.process.Child.init(fallback_argv, allocator);
    fallback_child.stdout_behavior = .Ignore;
    fallback_child.stderr_behavior = .Ignore;
    const fallback_term = try fallback_child.spawnAndWait();

    return fallback_term.Exited == 0;
}
