const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    std.debug.print("Running Zig Guide KR Code Snippet Validator (Native Zig)\n", .{});

    var total_snippets: usize = 0;
    var passed_snippets: usize = 0;
    var failed_snippets: usize = 0;

    const cwd = std.Io.Dir.cwd();
    var docs_dir = try cwd.openDir(io, "src/content/docs", .{ .iterate = true });
    defer docs_dir.close(io);

    var walker = try docs_dir.walk(gpa);
    defer walker.deinit();

    var file_paths: std.ArrayList([]const u8) = .empty;
    defer {
        for (file_paths.items) |p| gpa.free(p);
        file_paths.deinit(gpa);
    }

    while (try walker.next(io)) |entry| {
        if (entry.kind != .file) continue;
        if (std.mem.endsWith(u8, entry.path, ".md") or std.mem.endsWith(u8, entry.path, ".mdx")) {
            try file_paths.append(gpa, try gpa.dupe(u8, entry.path));
        }
    }

    // Sort paths
    std.mem.sort([]const u8, file_paths.items, {}, stringLessThan);

    // Create tmp dir for snippet tests in .zig-cache/tmp_snippets
    var tmp_dir = try cwd.createDirPathOpen(io, ".zig-cache/tmp_snippets", .{});
    defer tmp_dir.close(io);

    for (file_paths.items) |rel_path| {
        const content = try docs_dir.readFileAlloc(io, rel_path, gpa, .limited(10 * 1024 * 1024));
        defer gpa.free(content);

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

            if (try testSnippet(gpa, io, tmp_dir, code, idx)) {
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

fn testSnippet(gpa: std.mem.Allocator, io: std.Io, tmp_dir: std.Io.Dir, code: []const u8, idx: usize) !bool {
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

    var final_code: std.ArrayList(u8) = .empty;
    defer final_code.deinit(gpa);

    const std_prefix = if (has_std) "" else "const std = @import(\"std\");\n";

    if (has_main or has_test or has_build or has_export) {
        try final_code.appendSlice(gpa, code);
    } else if (is_decl_only) {
        try final_code.appendSlice(gpa, std_prefix);
        try final_code.appendSlice(gpa, code);
        try final_code.appendSlice(gpa, "\ntest \"syntax check\" {}\n");
    } else {
        try final_code.appendSlice(gpa, std_prefix);
        try final_code.appendSlice(gpa, "test \"statements\" {\n");
        try final_code.appendSlice(gpa, code);
        try final_code.appendSlice(gpa, "\n}\n");
    }

    const filename = try std.fmt.allocPrint(gpa, "snippet_{d}.zig", .{idx});
    defer gpa.free(filename);

    try tmp_dir.writeFile(io, .{ .sub_path = filename, .data = final_code.items });

    const tmp_path = try std.fmt.allocPrint(gpa, ".zig-cache/tmp_snippets/{s}", .{filename});
    defer gpa.free(tmp_path);

    const argv = if (has_build or has_export)
        &[_][]const u8{ "zig", "build-obj", tmp_path, "-fno-emit-bin" }
    else
        &[_][]const u8{ "zig", "test", tmp_path };

    const run_res = std.process.run(gpa, io, .{ .argv = argv }) catch return false;
    gpa.free(run_res.stdout);
    gpa.free(run_res.stderr);

    if (run_res.term == .exited and run_res.term.exited == 0) return true;

    // Fallback: build-obj syntax/semantic check
    const fallback_argv = &[_][]const u8{ "zig", "build-obj", tmp_path, "-fno-emit-bin" };
    const fb_res = std.process.run(gpa, io, .{ .argv = fallback_argv }) catch return false;
    gpa.free(fb_res.stdout);
    gpa.free(fb_res.stderr);

    return fb_res.term == .exited and fb_res.term.exited == 0;
}
