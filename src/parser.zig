const std = @import("std");
const utils = @import("utils.zig");

pub fn ParseObjFile() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    if (args.len < 2) {
        std.log.err("./scop [PATH OBJ] [PATH TEXTURE]", .{});
        return error.BadArgs;
    }

    const file = try utils.getRawFile(args[1], allocator);

    var lines = std.mem.splitScalar(u8, file, '\n');
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, ""))
            continue;
        const trimmed = std.mem.trim(u8, line, " ");
        if (contents.next()) |first| {
            if (std.mem.eql(u8, first, "v")) {} else if (std.mem.eql(u8, first, "vt")) {} else if (std.mem.eql(u8, first, "vn")) {} else if (std.mem.eql(u8, first, "vp")) {} else if (std.mem.eql(u8, first, "f")) {} else if (std.mem.eql(u8, first, "o")) {} else if (std.mem.eql(u8, first, "l")) {} else if (std.mem.eql(u8, first, "mtllib")) {} else if (std.mem.eql(u8, first, "usemtl")) {} else {
                return error.BadFile;
            }
        }
    }
}
