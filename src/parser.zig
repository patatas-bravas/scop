const std = @import("std");
const utils = @import("utils.zig");

pub const ObjData = struct {
    v_positions: std.ArrayList([3]f32),
};

fn getVertexPosition(
    contents: *SplitIterator,
    obj_data: *ObjData,
) !void {
    var i: usize = 0;
    var vertices: [3]f32 = undefined;
    while (contents.next()) |content| : (i += 1) {
        vertices[i] = std.fmt.parseFloat(f32, content) catch return error.Parsing;
    }
    return;
}

pub fn parseObjFile(path: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const file = try utils.getRawFile(args[1], allocator);

    var obj_data = RawObj{ .vertexs = std.ArrayList([3]f32).init(allocator) };

    var lines = std.mem.splitScalar(u8, file, '\n');
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "") || std.mem.eql(u8, line, "#"))
            continue;

        var contents = std.mem.splitScalar(u8, std.mem.trim(u8, line, " "), ' ');
        if (contents.next()) |data_type| {
            if (std.mem.eql(u8, data_type, "v")) {
                try getVertexPosition(&contents, &obj_data);
            } else {}
        }
    }
}
