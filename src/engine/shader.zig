const std = @import("std");
const gl = @import("opengl");

const utils = @import("../utils.zig");

pub const Shader = struct {
    vertex: c_uint,
    fragment: c_uint,
    program: c_uint,
    pub fn init() !Shader {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const allocator = arena.allocator();

        const raw_vertex_shader: []u8 = try utils.getRawFile("assets/shaders/shader.vert", allocator);
        defer allocator.free(raw_vertex_shader);

        const vertex_shader: c_uint = gl.CreateShader(gl.VERTEX_SHADER);
        gl.ShaderSource(vertex_shader, 1, @ptrCast(&raw_vertex_shader), null);
        gl.CompileShader(vertex_shader);
        try checkShaderCompiled(vertex_shader);
        defer gl.DeleteShader(vertex_shader);

        const raw_fragment_shader: []u8 = try utils.getRawFile("assets/shaders/shader.frag", allocator);
        defer allocator.free(raw_fragment_shader);

        const fragment_shader: c_uint = gl.CreateShader(gl.FRAGMENT_SHADER);
        gl.ShaderSource(fragment_shader, 1, @ptrCast(&raw_fragment_shader), null);
        gl.CompileShader(fragment_shader);
        try checkShaderCompiled(fragment_shader);
        defer gl.DeleteShader(fragment_shader);

        const shader_program: c_uint = gl.CreateProgram();
        gl.AttachShader(shader_program, vertex_shader);
        gl.AttachShader(shader_program, fragment_shader);
        gl.LinkProgram(shader_program);
        try checkShaderProgramLink(shader_program);
        gl.UseProgram(shader_program);
        return .{ .vertex = vertex_shader, .fragment = fragment_shader, .program = shader_program };
    }

    fn checkShaderCompiled(shader: c_uint) !void {
        var succes: c_int = undefined;
        var buffer: [512]u8 = undefined;
        gl.GetShaderiv(shader, gl.COMPILE_STATUS, @ptrCast(&succes));

        if (succes == 0) {
            gl.GetShaderInfoLog(shader, buffer.len, null, @ptrCast(&buffer));
            std.log.debug("{s}", .{buffer});
            return error.ShaderNotCompile;
        }
    }

    fn checkShaderProgramLink(program: c_uint) !void {
        var succes: c_int = undefined;
        var buffer: [512]u8 = undefined;
        gl.GetProgramiv(program, gl.LINK_STATUS, @ptrCast(&succes));
        if (succes == 0) {
            gl.GetProgramInfoLog(program, buffer.len, null, @ptrCast(&buffer));
            std.log.debug("{s}", .{buffer});
            return error.ProgramNotLink;
        }
    }
};
