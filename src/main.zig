const std = @import("std");
const gl = @import("opengl");
const glfw = @import("glfw");

const WITDH = 800;
const HEIGHT = 600;

var procs: gl.ProcTable = undefined;

pub fn main() !void {
    try glfw.init();
    defer glfw.terminate();

    glfw.windowHint(glfw.ContextVersionMajor, 4);
    glfw.windowHint(glfw.ContextVersionMinor, 6);
    glfw.windowHint(glfw.OpenGLProfile, glfw.OpenGLCoreProfile);

    const window = try glfw.createWindow(WITDH, HEIGHT, "scop", null, null);
    defer glfw.destroyWindow(window);

    glfw.makeContextCurrent(window);

    if (!procs.init(glfw.getProcAddress)) return error.InitFailed;

    gl.makeProcTableCurrent(&procs);
    defer gl.makeProcTableCurrent(null);

    gl.Viewport(0, 0, WITDH, HEIGHT);

    while (!glfw.windowShouldClose(window)) {
        const alpha: gl.float = 1;
        gl.ClearColor(1, 1, 1, alpha);
        gl.Clear(gl.COLOR_BUFFER_BIT);
        glfw.swapBuffers(window);
        glfw.pollEvents();
    }
}
