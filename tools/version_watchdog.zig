const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // 1. Fetch https://ziglang.org/download/index.json via std.http.Client
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    var body = std.ArrayList(u8).init(allocator);
    defer body.deinit();

    const res = try client.fetch(.{
        .location = .{ .url = "https://ziglang.org/download/index.json" },
        .response_storage = .{ .dynamic = &body },
        .headers = .{
            .user_agent = .{ .override = "ZigGuideKR-NativeWatcher/1.0" },
        },
    });

    if (res.status != .ok) {
        std.debug.print("{{\"error\": \"HTTP status {d}\"}}\n", .{@intFromEnum(res.status)});
        return;
    }

    // 2. Parse JSON
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, body.items, .{});
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

    // 3. Read tracked_versions.json
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

    var known_latest: []const u8 = "0.13.0";
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
