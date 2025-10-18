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

        const texture_data = try loader.loadBmp("assets/textures/cat.bmp", allocator);
        defer texture_data.deinit(allocator);
        var texture: c_uint = undefined;
        gl.GenTextures(1, @ptrCast(&texture));
        gl.BindTexture(gl.TEXTURE_2D, texture);

        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, texture_data.width, texture_data.height, 0, gl.BGR, gl.UNSIGNED_BYTE, @ptrCast(texture_data.pixel));
        gl.GenerateMipmap(gl.TEXTURE_2D);

        const texture_data2 = try loader.loadBmp("assets/textures/awesomeface.bmp", allocator);
        defer texture_data2.deinit(allocator);
        var texture2: c_uint = undefined;
        gl.GenTextures(1, @ptrCast(&texture2));
        gl.BindTexture(gl.TEXTURE_2D, texture2);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, texture_data2.width, texture_data2.height, 0, gl.BGR, gl.UNSIGNED_BYTE, @ptrCast(texture_data2.pixel));
        gl.GenerateMipmap(gl.TEXTURE_2D);

        gl.Uniform1i(gl.GetUniformLocation(shaders.program, "texture1"), 0);
        gl.Uniform1i(gl.GetUniformLocation(shaders.program, "texture2"), 1);
        while (!glfw.windowShouldClose(self.window)) {
            gl.ClearColor(0, 0, 0, 1);
            gl.Clear(gl.COLOR_BUFFER_BIT);

            gl.UseProgram(shaders.program);
            gl.ActiveTexture(gl.TEXTURE0);
            gl.BindTexture(gl.TEXTURE_2D, texture);
            gl.ActiveTexture(gl.TEXTURE1);
            gl.BindTexture(gl.TEXTURE_2D, texture2);
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
