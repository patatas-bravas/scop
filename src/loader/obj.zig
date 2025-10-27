const std = @import("std");
const utils = @import("../utils.zig");

pub const ObjFileError = error{
    InvalidFace,
    InvalidCharacter,
    InvalidVertex,
};

pub const ObjFileData = struct {
    vertexs: std.ArrayList(f32),
    faces: std.ArrayList(u32),

    pub fn init() ObjFileData {
        return .{
            .vertexs = .empty,
            .faces = .empty,
        };
    }

    pub fn deinit(self: *ObjFileData, allocator: std.mem.Allocator) void {
        self.vertexs.deinit(allocator);
        self.faces.deinit(allocator);
    }
};
pub fn loadFile(path: []const u8, gpa: std.mem.Allocator) !ObjFileData {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const allocator = arena.allocator();

    const file = utils.getRawFile(path, allocator) catch |err| {
        std.log.err("Failure to get raw data from the file from {s}: {s}", .{ path, @errorName(err) });
        return err;
    };

    var data = ObjFileData.init();
    errdefer data.deinit(gpa);

    var lines = std.mem.tokenizeScalar(u8, file, '\n');
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "") or std.mem.eql(u8, line, "#"))
            continue;

        const trim = std.mem.trim(u8, line, " ");
        var contents = std.mem.tokenizeScalar(u8, trim, ' ');
        if (contents.next()) |info_type| {
            if (std.mem.eql(u8, info_type, "#") or
                std.mem.eql(u8, info_type, "mtllib") or
                std.mem.eql(u8, info_type, "usemtl") or
                std.mem.eql(u8, info_type, "o") or
                std.mem.eql(u8, info_type, "s"))
                continue;

            if (std.mem.eql(u8, info_type, "v")) {
                var i: usize = 0;
                while (contents.next()) |content| : (i += 1) {
                    const vertex = try std.fmt.parseFloat(f32, content);
                    try data.vertexs.append(gpa, vertex);
                }
                if (i != 3)
                    return ObjFileError.InvalidVertex;
            } else if (std.mem.eql(u8, info_type, "f")) {
                var face: std.ArrayList(u32) = .empty;
                defer face.deinit(allocator);

                while (contents.next()) |content| {
                    const value = try std.fmt.parseInt(u32, content, 10);
                    try face.append(allocator, value);
                }

                if (face.items.len < 3)
                    return ObjFileError.InvalidFace;

                var i: usize = 1;
                while (i < face.items.len - 1) : (i += 1) {
                    try data.faces.append(gpa, face.items[0] - 1);
                    try data.faces.append(gpa, face.items[i] - 1);
                    try data.faces.append(gpa, face.items[i + 1] - 1);
                }
            } else {
                return ObjFileError.InvalidCharacter;
            }
        }
    }

    return data;
}
