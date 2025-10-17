const std = @import("std");
const gl = @import("opengl");

pub const Vao = struct {
    pub fn init() c_uint {
        var vao: c_uint = undefined;
        gl.GenVertexArrays(1, @ptrCast(&vao));
        gl.BindVertexArray(vao);
        return vao;
    }
};

pub const Vbo = struct {
    pub fn init(vertices: []const f32) c_uint {
        var vbo: c_uint = undefined;
        gl.GenBuffers(1, @ptrCast(&vbo));
        gl.BindBuffer(gl.ARRAY_BUFFER, vbo);
        gl.BufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * vertices.len), @ptrCast(vertices), gl.STATIC_DRAW);

        gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * @sizeOf(f32), 0);
        gl.EnableVertexAttribArray(0);

        gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 8 * @sizeOf(f32), 3 * @sizeOf(f32));
        gl.EnableVertexAttribArray(1);

        gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 8 * @sizeOf(f32), 6 * @sizeOf(f32));
        gl.EnableVertexAttribArray(2);
        return vbo;
    }
};

pub const Ebo = struct {
    pub fn init(indices: []const u32) c_uint {
        var ebo: c_uint = undefined;
        gl.GenBuffers(1, @ptrCast(&ebo));
        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo);
        gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, @intCast(@sizeOf(u32) * indices.len), @ptrCast(indices), gl.STATIC_DRAW);
        return ebo;
    }
};
