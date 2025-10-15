const std = @import("std");
const gl = @import("opengl");

const engine = @import("engine.zig");
const utils = @import("utils.zig");

pub const std_options: std.Options = .{
    .logFn = utils.log,
};

var procs: gl.ProcTable = undefined;

pub fn main() !void {
    var scop = try engine.Scop.init();
    defer scop.deinit();

    try scop.run();
}
