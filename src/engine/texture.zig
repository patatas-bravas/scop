const std = @import("std");
const gl = @import("opengl");

const loader = @import("../loader.zig");

const GL_ACTIVE_TEXTURES = [_]c_int{ gl.TEXTURE0, gl.TEXTURE1 };

pub const Textures = struct {
    size: usize,
    textures: [2]c_uint,

    pub fn init() Textures {
        return .{ .size = 0, .textures = undefined };
    }

    pub fn createTexture(self: *Textures, path: []const u8, name: [:0]const u8, shader_program: c_uint, allocator: std.mem.Allocator) !void {
        const data = try loader.bmp.loadFile(path, allocator);
        defer data.deinit(allocator);
        var texture: c_uint = undefined;
        gl.GenTextures(1, @ptrCast(&texture));
        gl.BindTexture(gl.TEXTURE_2D, texture);

        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, data.width, data.height, 0, gl.BGR, gl.UNSIGNED_BYTE, @ptrCast(data.pixel));
        gl.GenerateMipmap(gl.TEXTURE_2D);
        gl.Uniform1i(gl.GetUniformLocation(shader_program, name), @intCast(self.size));

        self.textures[self.size] = texture;
        self.size += 1;
    }

    pub fn activeTexture(self: *Textures) void {
        inline for (self.textures, GL_ACTIVE_TEXTURES) |texture, n| {
            gl.ActiveTexture(n);
            gl.BindTexture(gl.TEXTURE_2D, texture);
        }
    }
};
