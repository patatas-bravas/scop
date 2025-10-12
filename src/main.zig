const std = @import("std");
const gl = @import("opengl");
const glfw = @import("zglfw.zig");
const parser = @import("parser.zig");

pub const std_options: std.Options = .{
    .logFn = log,
};

pub fn log(
    comptime level: std.log.Level,
    comptime scope: @Type(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {
    const level_txt = switch (level) {
        std.log.Level.debug => "[DEBUG]",
        std.log.Level.info => "[INFO]",
        std.log.Level.warn => "[WARN]",
        std.log.Level.err => "[ERR]",
    };

    const scope_prefix = if (scope != .default) "[" ++ @tagName(scope) ++ "]" else "";

    const stderr = std.debug.lockStderrWriter(&.{});
    defer std.debug.unlockStderrWriter();
    stderr.print(level_txt ++ scope_prefix ++ ": " ++ format ++ "\n", args) catch return;
}

const WITDH = 800;
const HEIGHT = 600;

var procs: gl.ProcTable = undefined;

pub fn main() !void {
    try parser.ParseObjFile();
    if (glfw.Init() == glfw.FALSE)
        return error.InitFailed;
    defer glfw.Terminate();

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4);
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6);
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);

    const window = glfw.CreateWindow(WITDH, HEIGHT, "scop", null, null) orelse return;
    defer glfw.DestroyWindow(window);

    glfw.MakeContextCurrent(window);

    if (!procs.init(glfw.GetProcAddress))
        return error.InitFailed;

    gl.makeProcTableCurrent(&procs);
    defer gl.makeProcTableCurrent(null);

    gl.Viewport(0, 0, WITDH, HEIGHT);

    while (glfw.WindowShouldClose(window) == 0) {
        const alpha: gl.float = 1;
        gl.ClearColor(1, 1, 1, alpha);
        gl.Clear(gl.COLOR_BUFFER_BIT);
        glfw.SwapBuffers(window);
        glfw.PollEvents();
    }
}
