const std = @import("std");
const gl = @import("opengl");

const glfw = @import("zglfw.zig");
const loader = @import("loader.zig");

const WITDH = 800;
const HEIGHT = 600;

const VERSION_MAJOR = 4;
const VERSION_MINOR = 6;

pub var procs: gl.ProcTable = undefined;

pub const Scop = struct {
    window: *glfw.Window,

    pub fn init() !Scop {
        if (glfw.init() == glfw.FALSE)
            return error.InitFailed;
        glfw.windowHint(glfw.CONTEXT_VERSION_MAJOR, VERSION_MAJOR);
        glfw.windowHint(glfw.CONTEXT_VERSION_MINOR, VERSION_MINOR);
        glfw.windowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);

        const window = glfw.createWindow(WITDH, HEIGHT, "scop", null, null) orelse return error.FailedToCreateWindow;
        glfw.makeContextCurrent(window);

        if (!procs.init(glfw.GetProcAddress))
            return error.InitFailed;
        gl.makeProcTableCurrent(&procs);
        gl.Viewport(0, 0, WITDH, HEIGHT);

        return Scop{ .window = window };
    }

    pub fn run(self: *Scop) !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
        const allocator = gpa.allocator();
        defer {
            const status = gpa.deinit();
            if (status == .leak)
                @panic("[LEAK]: run()");
        }

        const data = try loader.loadObj("assets/objects/42.obj", allocator);

        const vertices = data.positions.items;

        const vbo: u32 = undefined;
        gl.GenBuffers(1, &vbo);
        gl.BindBuffer(gl.ARRAY_BUFFER, vbo);
        gl.BufferData(gl.ARRAY_BUFFER, @sizeOf(vertices.ptr), vertices.ptr, gl.STATIC_DRAW);

        while (glfw.windowShouldClose(self.window) == 0) {
            gl.ClearColor(1, 1, 1, 1);
            gl.Clear(gl.COLOR_BUFFER_BIT);
            glfw.swapBuffers(self.window);
            glfw.pollEvents();
        }
    }

    pub fn clean(self: *Scop) !void {
        gl.makeProcTableCurrent(null);
        glfw.destroyWindow(self.window);
        glfw.terminate();
    }
};
