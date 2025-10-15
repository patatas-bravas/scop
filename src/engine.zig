const std = @import("std");
const gl = @import("opengl");

const glfw = @import("zglfw.zig");
const loader = @import("loader.zig");
const utils = @import("utils.zig");

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

        var data = try loader.loadObj("assets/objects/42.obj", allocator);
        defer data.deinit(allocator);

        const vertices = data.vertexs.items;
        var vbo: c_uint = undefined;
        gl.GenBuffers(1, @ptrCast(&vbo));
        gl.BindBuffer(gl.ARRAY_BUFFER, vbo);
        gl.BufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * vertices.len), vertices.ptr, gl.STATIC_DRAW);

        const raw_vertex_shader: []u8 = try utils.getRawFile("assets/shaders/shader.vert", allocator);
        defer allocator.free(raw_vertex_shader);

        const vertex_shader: c_uint = gl.CreateShader(gl.VERTEX_SHADER);
        gl.ShaderSource(vertex_shader, 1, @ptrCast(&raw_vertex_shader), null);
        gl.CompileShader(vertex_shader);
        try checkShaderCompiled(vertex_shader);

        const raw_fragment_shader: []u8 = try utils.getRawFile("assets/shaders/shader.frag", allocator);
        defer allocator.free(raw_fragment_shader);

        const fragment_shader: c_uint = gl.CreateShader(gl.FRAGMENT_SHADER);
        gl.ShaderSource(fragment_shader, 1, @ptrCast(&raw_fragment_shader), null);
        gl.CompileShader(fragment_shader);
        try checkShaderCompiled(fragment_shader);

        const shader_program: c_uint = gl.CreateShaderProgram();
        gl.AttachShader(shader_program, vertex_shader);
        gl.AttachShader(shader_program, fragment_shader);
        gl.LinkProgram(shader_program);
        try checkShaderProgramLink(shader_program);
        gl.UseProgram(shader_program);

        gl.DeleteShader(vertex_shader);
        gl.DeleteShader(fragment_shader);

        while (glfw.windowShouldClose(self.window) == 0) {
            gl.ClearColor(1, 1, 1, 1);
            gl.Clear(gl.COLOR_BUFFER_BIT);
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
