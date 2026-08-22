const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Fetch https://ziglang.org/download/index.json via curl child process (robust across all Zig std changes)
    const argv = &[_][]const u8{ "curl", "-sSL", "https://ziglang.org/download/index.json" };
    var child = std.process.Child.init(argv, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Ignore;

    try child.spawn();

    const body = try child.stdout.?.readToEndAlloc(allocator, 10 * 1024 * 1024);
    defer allocator.free(body);

    _ = try child.wait();

    // Parse JSON
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, body, .{});
    defer parsed.deinit();

    if (parsed.value != .object) {
        std.debug.print("{{\"error\": \"invalid JSON root\"}}\n", .{});
        return;
    }

    // Find latest release (first non-master key)
    var latest_version: ?[]const u8 = null;
    var it = parsed.value.object.iterator();
    while (it.next()) |entry| {
        if (!std.mem.eql(u8, entry.key_ptr.*, "master")) {
            latest_version = entry.key_ptr.*;
            break;
        }
    }

    const latest = latest_version orelse {
        std.debug.print("{{\"error\": \"no release version found\"}}\n", .{});
        return;
    };

    // Read tracked_versions.json
    const tracked_path = "tracked_versions.json";
    var tracked_file = std.fs.cwd().openFile(tracked_path, .{}) catch null;

    if (tracked_file == null) {
        // Initialize file
        const new_file = try std.fs.cwd().createFile(tracked_path, .{});
        defer new_file.close();
        try new_file.writer().print("{{\n  \"latest_release\": \"{s}\"\n}}\n", .{latest});
        std.debug.print("{{\"status\": \"initialized\", \"current_version\": \"{s}\"}}\n", .{latest});
        return;
    }
    defer tracked_file.?.close();

    const tracked_content = try tracked_file.?.readToEndAlloc(allocator, 64 * 1024);
    defer allocator.free(tracked_content);

    const tracked_parsed = try std.json.parseFromSlice(std.json.Value, allocator, tracked_content, .{});
    defer tracked_parsed.deinit();

    var known_latest: []const u8 = "0.16.0";
    if (tracked_parsed.value == .object) {
        if (tracked_parsed.value.object.get("latest_release")) |v| {
            if (v == .string) known_latest = v.string;
        }
    }

    if (std.mem.eql(u8, latest, known_latest)) {
        std.debug.print("{{\"status\": \"no_change\", \"current_version\": \"{s}\"}}\n", .{known_latest});
    } else {
        std.debug.print(
            "{{\"status\": \"new_version_detected\", \"old_version\": \"{s}\", \"new_version\": \"{s}\"}}\n",
            .{ known_latest, latest },
        );
    }
}
