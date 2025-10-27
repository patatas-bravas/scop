const std = @import("std");
const utils = @import("../utils.zig");

const BmpFileError = error{InvalidBmpFile};

pub const BmpFileData = struct {
    pixel: []u8,
    width: c_int,
    height: c_int,

    pub fn init(pixel: []u8, width: c_int, height: c_int) BmpFileData {
        return .{ .pixel = pixel, .width = width, .height = height };
    }

    pub fn deinit(self: *const BmpFileData, allocator: std.mem.Allocator) void {
        allocator.free(self.pixel);
    }
};

const BMP_HEADER_SIZE = 54;
pub fn loadFile(path: []const u8, gpa: std.mem.Allocator) !BmpFileData {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const allocator = arena.allocator();

    const file = utils.getRawFile(path, allocator) catch |err| {
        std.log.err("Failure to get raw data from the file from {s}: {s}", .{ path, @errorName(err) });
        return err;
    };
    if (file.len < BMP_HEADER_SIZE)
        return BmpFileError.InvalidBmpFile;

    const start = std.mem.readInt(u32, file[10..14], .little);
    const width = std.mem.readInt(i32, file[18..22], .little);
    const height = std.mem.readInt(i32, file[22..26], .little);
    return BmpFileData.init(try gpa.dupe(u8, file[start..]), @intCast(width), @intCast(height));
}
