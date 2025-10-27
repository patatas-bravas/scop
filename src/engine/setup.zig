const std = @import("std");
const gl = @import("opengl");
const glfw = @import("glfw");

var procs: gl.ProcTable = undefined;

const WITDH = 1600;
const HEIGHT = 1200;

const VERSION_MAJOR = 4;
const VERSION_MINOR = 6;

pub fn context() !*glfw.Window {
    try glfw.init();
    glfw.windowHint(glfw.ContextVersionMajor, VERSION_MAJOR);
    glfw.windowHint(glfw.ContextVersionMinor, VERSION_MINOR);
    glfw.windowHint(glfw.OpenGLProfile, glfw.OpenGLCoreProfile);

    const window = try glfw.createWindow(WITDH, HEIGHT, "scop", null, null);
    glfw.makeContextCurrent(window);

    _ = glfw.setFramebufferSizeCallback(window, framebufferSizeCallback);

    if (!procs.init(glfw.getProcAddress))
        return error.setupOpengl;
    gl.makeProcTableCurrent(&procs);

    var width: c_int = undefined;
    var height: c_int = undefined;
    glfw.getFramebufferSize(window, &width, &height);
    gl.Viewport(0, 0, width, height);

    return window;
}

fn framebufferSizeCallback(_: ?*glfw.Window, width: c_int, height: c_int) callconv(.c) void {
    gl.Viewport(0, 0, width, height);
}
