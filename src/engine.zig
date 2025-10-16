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
        glfw.setFramebufferSizeCallback(window, framebufferSizeCallback);

        if (!procs.init(glfw.GetProcAddress))
            return error.InitFailed;
        gl.makeProcTableCurrent(&procs);
        var fb_width: c_int = undefined;
        var fb_height: c_int = undefined;
        glfw.getFramebufferSize(window, &fb_width, &fb_height);
        gl.Viewport(0, 0, fb_width, fb_height);

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
        var vao: c_uint = undefined;
        gl.GenVertexArrays(1, @ptrCast(&vao));
        gl.BindVertexArray(vao);
        const vertices = [_]f32{
            0.5,  -0.5, 0.0, 1.0, 0.0, 0.0,
            -0.5, -0.5, 0.0, 0.0, 1.0, 0.0,
            0.0,  0.5,  0.0, 0.0, 0.0, 1.0,
        };

        var vbo: c_uint = undefined;
        gl.GenBuffers(1, @ptrCast(&vbo));
        gl.BindBuffer(gl.ARRAY_BUFFER, vbo);
        gl.BufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * vertices.len), &vertices, gl.STATIC_DRAW);
        gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), 0);
        gl.EnableVertexAttribArray(0);

        gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), 3 * @sizeOf(f32));
        gl.EnableVertexAttribArray(1);

        const indices = [_]u32{
            0, 1, 2,
        };
        var ebo: c_uint = undefined;
        gl.GenBuffers(1, @ptrCast(&ebo));
        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo);
        gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, @intCast(@sizeOf(u32) * indices.len), &indices, gl.STATIC_DRAW);

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

        const shader_program: c_uint = gl.CreateProgram();
        gl.AttachShader(shader_program, vertex_shader);
        gl.AttachShader(shader_program, fragment_shader);
        gl.LinkProgram(shader_program);
        try checkShaderProgramLink(shader_program);
        gl.UseProgram(shader_program);

        gl.DeleteShader(vertex_shader);
        gl.DeleteShader(fragment_shader);

        // const texture = try loader.loadBmp("assets/textures/cat.bmp", allocator);

        while (glfw.windowShouldClose(self.window) == 0) {
            gl.ClearColor(1, 1, 1, 1);
            gl.Clear(gl.COLOR_BUFFER_BIT);

            gl.UseProgram(shader_program);
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

fn framebufferSizeCallback(_: ?*glfw.Window, width: c_int, height: c_int) callconv(.c) void {
    gl.Viewport(0, 0, width, height);
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
