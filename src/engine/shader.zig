const std = @import("std");
const gl = @import("opengl");

const utils = @import("../utils.zig");

pub fn createShaderProgram(gpa: std.mem.Allocator) !c_uint {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const allocator = arena.allocator();

    var shaders: [2]c_uint = undefined;

    shaders[0] = try createShader("assets/shaders/shader.vert", gl.VERTEX_SHADER, allocator);
    shaders[1] = try createShader("assets/shaders/shader.frag", gl.FRAGMENT_SHADER, allocator);
    const shader_program: c_uint = gl.CreateProgram();

    inline for (shaders) |shader| {
        gl.AttachShader(shader_program, shader);
    }
    gl.LinkProgram(shader_program);
    try checkShaderProgramLink(shader_program);
    gl.UseProgram(shader_program);
    return shader_program;
}

fn createShader(path: []const u8, shader_type: c_uint, allocator: std.mem.Allocator) !c_uint {
    const raw_shader: []u8 = try utils.getRawFile(path, allocator);
    const shader: c_uint = gl.CreateShader(shader_type);
    gl.ShaderSource(shader, 1, @ptrCast(&raw_shader), null);
    gl.CompileShader(shader);
    try checkShaderCompiled(shader);
    return shader;
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
