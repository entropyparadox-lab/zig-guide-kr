const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    // Fetch https://ziglang.org/download/index.json via curl child process (robust across all Zig std changes)
    const argv = &[_][]const u8{ "curl", "-sSL", "https://ziglang.org/download/index.json" };
    const res = try std.process.run(gpa, io, .{
        .argv = argv,
    });
    defer {
        gpa.free(res.stdout);
        gpa.free(res.stderr);
    }

    if (res.term != .exited or res.term.exited != 0) {
        std.debug.print("{{\"error\": \"failed to run curl\"}}\n", .{});
        return;
    }

    // Parse JSON
    const parsed = try std.json.parseFromSlice(std.json.Value, gpa, res.stdout, .{});
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
    const cwd = std.Io.Dir.cwd();

    const tracked_content = cwd.readFileAlloc(io, tracked_path, gpa, .limited(64 * 1024)) catch |err| switch (err) {
        error.FileNotFound => {
            // Initialize file
            const init_json = try std.fmt.allocPrint(gpa, "{{\n  \"latest_release\": \"{s}\"\n}}\n", .{latest});
            defer gpa.free(init_json);
            try cwd.writeFile(io, .{ .sub_path = tracked_path, .data = init_json });
            std.debug.print("{{\"status\": \"initialized\", \"current_version\": \"{s}\"}}\n", .{latest});
            return;
        },
        else => |e| return e,
    };
    defer gpa.free(tracked_content);

    const tracked_parsed = try std.json.parseFromSlice(std.json.Value, gpa, tracked_content, .{});
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
