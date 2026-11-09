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
        // Versioned archives are not a claim of compatibility with the current compiler.
        if (std.mem.startsWith(u8, entry.path, "docs/0.16.0/")) continue;
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
    const source = try gpa.dupeSentinel(u8, code, 0);
    defer gpa.free(source);
    var tokenizer = std.zig.Tokenizer.init(source);
    var has_main = false;
    var has_build = false;
    var has_test = false;
    var has_export = false;
    while (true) {
        const token = tokenizer.next();
        switch (token.tag) {
            .eof => break,
            .keyword_test => has_test = true,
            .keyword_export => has_export = true,
            .keyword_fn => {
                const name = tokenizer.next();
                if (name.tag == .identifier) {
                    const text = source[name.loc.start..name.loc.end];
                    has_main = has_main or std.mem.eql(u8, text, "main");
                    has_build = has_build or std.mem.eql(u8, text, "build");
                }
            },
            else => {},
        }
    }

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

    const argv = if (has_main)
        &[_][]const u8{ "zig", "build-exe", tmp_path, "-fno-emit-bin", "-lc" }
    else if (has_build)
        // Evaluate the build graph, including the build function body; do not build missing example sources.
        &[_][]const u8{ "zig", "build", "--build-file", tmp_path, "--help" }
    else if (has_export)
        &[_][]const u8{ "zig", "build-obj", tmp_path, "-fno-emit-bin" }
    else
        &[_][]const u8{ "zig", "test", tmp_path, "-lc" };

    if (!try runValidation(gpa, io, argv)) return false;
    // Tests may coexist with main/build/export declarations: run both required checks.
    if (has_test and (has_main or has_build or has_export)) {
        if (!try runValidation(gpa, io, &.{ "zig", "test", tmp_path, "-lc" })) return false;
    }
    if (has_build and has_main) {
        if (!try runValidation(gpa, io, &.{ "zig", "build", "--build-file", tmp_path, "--help" })) return false;
    }
    return true;
}

fn runValidation(gpa: std.mem.Allocator, io: std.Io, argv: []const []const u8) !bool {
    const run_res = std.process.run(gpa, io, .{ .argv = argv }) catch return false;
    gpa.free(run_res.stdout);
    defer gpa.free(run_res.stderr);
    const passed = run_res.term == .exited and run_res.term.exited == 0;
    if (!passed) std.debug.print("{s}\n", .{run_res.stderr});
    return passed;
}
