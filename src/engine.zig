const std = @import("std");
const glfw = @import("glfw");
const gl = @import("opengl");

const loader = @import("loader.zig");
const utils = @import("utils.zig");

const setup = @import("engine/setup.zig");
const buffer = @import("engine/buffer.zig");
const shader = @import("engine/shader.zig");

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

        const vertices = [_]f32{
            0.5,  0.5,  0.0, 1.0, 0.0, 0.0, 1.0, 1.0,
            0.5,  -0.5, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0,
            -0.5, -0.5, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0,
            -0.5, 0.5,  0.0, 1.0, 1.0, 0.0, 0.0, 1.0,
        };

        _ = buffer.Vbo.init(&vertices);

        const indices = [_]u32{ 0, 1, 2, 0, 2, 3 };

        _ = buffer.Ebo.init(&indices);

        const shaders = try shader.Shader.init();

        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.MIRRORED_REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR_MIPMAP_LINEAR);

        const texture_data = try loader.loadBmp("assets/textures/cat.bmp", allocator);
        defer texture_data.deinit(allocator);
        var texture: c_uint = undefined;
        gl.GenTextures(1, @ptrCast(&texture));
        gl.BindTexture(gl.TEXTURE_2D, texture);
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, texture_data.width, texture_data.height, 0, gl.BGR, gl.UNSIGNED_BYTE, @ptrCast(texture_data.pixel));
        gl.GenerateMipmap(gl.TEXTURE_2D);

        while (!glfw.windowShouldClose(self.window)) {
            gl.ClearColor(1, 1, 1, 1);
            gl.Clear(gl.COLOR_BUFFER_BIT);

            gl.UseProgram(shaders.program);
            gl.BindTexture(gl.TEXTURE_2D, texture);
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
