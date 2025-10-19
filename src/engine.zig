const std = @import("std");
const glfw = @import("glfw");
const gl = @import("opengl");

const loader = @import("loader.zig");
const utils = @import("utils.zig");

const setup = @import("engine/setup.zig");
const buffer = @import("engine/buffer.zig");
const shader = @import("engine/shader.zig");
const texture = @import("engine/texture.zig");

pub const Scop = struct {
    window: *glfw.Window,

    pub fn init() !Scop {
        const window = try setup.context();
        return .{ .window = window };
    }

    pub fn run(self: *Scop) !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
        const allocator = gpa.allocator();
        defer {
            const status = gpa.deinit();
            if (status == .leak)
                @panic("[LEAK]: run()");
        }
        const vao = buffer.Vao.init();
        defer buffer.Vao.deinit(vao);

        const vertices = [_]f32{
            0.5,  0.5,  0.0, 1.0, 0.0, 0.0, 1.0, 1.0,
            0.5,  -0.5, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0,
            -0.5, -0.5, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0,
            -0.5, 0.5,  0.0, 1.0, 1.0, 0.0, 0.0, 1.0,
        };

        const vbo = buffer.Vbo.init(&vertices);
        defer buffer.Vbo.deinit(vbo);

        const indices = [_]u32{ 0, 1, 2, 0, 2, 3 };

        const ebo = buffer.Ebo.init(&indices);
        defer buffer.Ebo.deinit(ebo);

        const shaders = try shader.Shader.init();

        var textures = texture.Generator.init();

        try textures.createTexture("assets/textures/cat.bmp", "texture1", shaders.program, allocator);

        try textures.createTexture("assets/textures/awesomeface.bmp", "lol", shaders.program, allocator);

        while (!glfw.windowShouldClose(self.window)) {
            gl.ClearColor(0, 0, 0, 1);
            gl.Clear(gl.COLOR_BUFFER_BIT);

            gl.UseProgram(shaders.program);
            textures.activeTexture();
            gl.BindVertexArray(vao);
            gl.DrawElements(gl.TRIANGLES, @intCast(indices.len), gl.UNSIGNED_INT, 0);

            glfw.swapBuffers(self.window);
            glfw.pollEvents();
        }
    }

    pub fn deinit(self: *Scop) void {
        gl.makeProcTableCurrent(null);
        glfw.destroyWindow(self.window);
        glfw.terminate();
    }
};
