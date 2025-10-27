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
        var data = try loader.obj.loadFile("assets/objects/42.obj", allocator);
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

        try textures.createTexture("assets/textures/brick.bmp", "basic", shader_program, allocator);

        gl.Enable(gl.DEPTH_TEST);
        var view = math.matrix.createIdentity();
        view = math.matrix.scalingScalar(view, 0.3);
        const view_u: c_int = gl.GetUniformLocation(shader_program, "view");
        var model = math.matrix.createIdentity();
        const model_u: c_int = gl.GetUniformLocation(shader_program, "model");
        var projection = math.matrix.createOrtho(5, 15, -3, 7, 0.1, 100);
        const projection_u: c_int = gl.GetUniformLocation(shader_program, "projection");

        while (!glfw.windowShouldClose(self.window)) {
            gl.ClearColor(1, 0.3, 0.5, 1);
            gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

            model = math.matrix.rotationYMat(model, @floatCast(glfw.getTime()));

            gl.UniformMatrix4fv(model_u, 1, gl.FALSE, @ptrCast(&model));
            gl.UniformMatrix4fv(view_u, 1, gl.FALSE, @ptrCast(&view));
            gl.UniformMatrix4fv(projection_u, 1, gl.FALSE, @ptrCast(&projection));

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
