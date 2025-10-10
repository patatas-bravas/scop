const std = @import("std");
const gl = @import("opengl");
const glfw = @import("zglfw.zig");

const WITDH = 800;
const HEIGHT = 600;

var procs: gl.ProcTable = undefined;

pub fn main() !void {
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
