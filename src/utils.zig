const std = @import("std");

pub fn log(
    comptime level: std.log.Level,
    comptime scope: @Type(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {
    const level_log = switch (level) {
        std.log.Level.debug => "[DEBUG]",
        std.log.Level.info => "[INFO]",
        std.log.Level.warn => "[WARN]",
        std.log.Level.err => "[ERR]",
    };

    const scope_log = if (scope != .default) "[" ++ @tagName(scope) ++ "]" else "";

    const stderr = std.debug.lockStderrWriter(&.{});
    defer std.debug.unlockStderrWriter();
    stderr.print(level_log ++ scope_log ++ ": " ++ format ++ "\n", args) catch return;
}

pub fn getRawFile(path: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const stat = try file.stat();
    const buffer = try allocator.alloc(u8, stat.size);
    _ = try file.readAll(buffer);

    return buffer;
}
