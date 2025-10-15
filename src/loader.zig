const std = @import("std");
const utils = @import("utils.zig");

pub const LoaderError = error{
    InvalidFace,
    InvalidCharacter,
    InvalidVertex,
};

pub const LoaderData = struct {
    vertexs: std.ArrayList(f32),
    faces: std.ArrayList(i32),

    pub fn init() LoaderData {
        return .{
            .vertexs = .empty,
            .faces = .empty,
        };
    }

    pub fn deinit(self: *LoaderData, allocator: std.mem.Allocator) void {
        self.vertexs.deinit(allocator);
        self.faces.deinit(allocator);
    }
};

pub fn loadObj(path: []const u8, gpa: std.mem.Allocator) !LoaderData {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const file = utils.getRawFile(path, allocator) catch |err| {
        std.log.err("Failure to get raw data from the file from {s}: {s}", .{ path, @errorName(err) });
        return err;
    };

    var data = LoaderData.init();

    var lines = std.mem.splitScalar(u8, file, '\n');
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "") or std.mem.eql(u8, line, "#"))
            continue;

        var contents = std.mem.splitScalar(u8, std.mem.trim(u8, line, " "), ' ');
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
                    return LoaderError.InvalidVertex;
            } else if (std.mem.eql(u8, info_type, "f")) {
                var face: std.ArrayList(i32) = .empty;
                defer face.deinit(allocator);

                while (contents.next()) |content| {
                    const value = try std.fmt.parseInt(i32, content, 10);
                    try face.append(allocator, value);
                }

                if (face.items.len < 3)
                    return LoaderError.InvalidFace;

                var i: usize = 1;
                while (i < face.items.len - 1) : (i += 1) {
                    try data.faces.append(gpa, face.items[0] - 1);
                    try data.faces.append(gpa, face.items[i] - 1);
                    try data.faces.append(gpa, face.items[i + 1] - 1);
                }
            } else {
                return LoaderError.InvalidCharacter;
            }
        }
    }

    return data;
}
