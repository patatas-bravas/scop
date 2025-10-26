const std = @import("std");
const glfw = @import("glfw");
const gl = @import("opengl");

const loader = @import("loader.zig");
const utils = @import("utils.zig");
const math = @import("math.zig");

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
        var data = try loader.loadObj("assets/objects/cube.obj", allocator);
        defer data.deinit(allocator);
        const vertices: []f32 = data.vertexs.items;
        const indices: []u32 = data.faces.items;

        const vao = buffer.createVAO();
        defer buffer.deleteVAO(vao);

        const vbo = buffer.createVBO(vertices);
        defer buffer.deleteVBO(vbo);

        const ebo = buffer.createEBO(indices);
        defer buffer.deleteEBO(ebo);

        const shader_program = try shader.createShaderProgram(allocator);

        var textures = texture.Textures.init();

        try textures.createTexture("assets/textures/cat.bmp", "texture", shader_program, allocator);

        while (!glfw.windowShouldClose(self.window)) {
            gl.ClearColor(0, 0, 0, 1);
            gl.Clear(gl.COLOR_BUFFER_BIT);

            var trans = math.createIdentityMat();
            trans = math.rotationZMat(trans, @floatCast(glfw.getTime()));

            const transform: c_int = gl.GetUniformLocation(shader_program, "transform");
            gl.UniformMatrix4fv(transform, 1, gl.FALSE, @ptrCast(&trans));

            gl.UseProgram(shader_program);
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
