const std = @import("std");
const utils = @import("utils.zig");

pub const ObjData = struct {
    positions: std.ArrayList(f32),
    faces: std.ArrayList(i32),
};

pub fn loadObj(path: []const u8, gpa: std.mem.Allocator) !ObjData {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const file = try utils.getRawFile(path, allocator);

    var data = ObjData{
        .positions = std.ArrayList(f32).init(gpa),
        .faces = std.ArrayList(i32).init(gpa),
    };

    var lines = std.mem.splitScalar(u8, file, '\n');
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "") or std.mem.eql(u8, line, "#"))
            continue;

        var contents = std.mem.splitScalar(u8, std.mem.trim(u8, line, " "), ' ');
        if (contents.next()) |data_type| {
            if (std.mem.eql(u8, data_type, "#") or
                std.mem.eql(u8, data_type, "mtllib") or
                std.mem.eql(u8, data_type, "usemtl") or
                std.mem.eql(u8, data_type, "o") or
                std.mem.eql(u8, data_type, "s"))
                continue;

            if (std.mem.eql(u8, data_type, "v")) {
                var i: usize = 0;
                while (contents.next()) |content| : (i += 1) {
                    const position = try std.fmt.parseFloat(f32, content);
                    try data.positions.append(position);
                }
                if (i != 3)
                    return error.InvalidPosition;
            } else if (std.mem.eql(u8, data_type, "f")) {
                var face = std.ArrayList(i32).init(allocator);
                defer face.deinit();

                while (contents.next()) |content| {
                    const value = try std.fmt.parseInt(i32, content);
                    try face.append(value);
                }

                if (face.items.len < 3)
                    return error.InvalidFace;

                var i: usize = 1;
                while (i < face.item.len - 1) : (i += 1) {
                    try data.faces.append(allocator, face[0] - 1);
                    try data.faces.append(allocator, face[i] - 1);
                    try data.faces.append(allocator, face[i + 1] - 1);
                }
            } else {
                return error.InvalidCharacter;
            }
        }
    }
    return data;
}
