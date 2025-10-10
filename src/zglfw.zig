const c = @cImport(@cInclude("GLFW/glfw3.h"));

pub const FALSE = c.GLFW_FALSE;
pub const TRUE = c.GLFW_TRUE;
pub const CONTEXT_VERSION_MAJOR = c.GLFW_CONTEXT_VERSION_MAJOR;
pub const CONTEXT_VERSION_MINOR = c.GLFW_CONTEXT_VERSION_MINOR;
pub const OPENGL_PROFILE = c.GLFW_OPENGL_PROFILE;
pub const OPENGL_CORE_PROFILE = c.GLFW_OPENGL_CORE_PROFILE;

pub const GetProcAddress = c.glfwGetProcAddress;

pub fn Init() c_int {
    return c.glfwInit();
}

pub fn WindowHint(hint: c_int, value: c_int) void {
    return c.glfwWindowHint(hint, value);
}

pub fn Terminate() void {
    return c.glfwTerminate();
}

pub fn CreateWindow(width: c_int, height: c_int, title: [*:0]const u8, monitor: ?*c.GLFWmonitor, share: ?*c.GLFWwindow) ?*c.GLFWwindow {
    return c.glfwCreateWindow(width, height, title, monitor, share);
}

pub fn DestroyWindow(window: *c.GLFWwindow) void {
    return c.glfwDestroyWindow(window);
}

pub fn MakeContextCurrent(window: *c.GLFWwindow) void {
    return c.glfwMakeContextCurrent(window);
}

pub fn WindowShouldClose(window: *c.GLFWwindow) c_int {
    return c.glfwWindowShouldClose(window);
}

pub fn SwapBuffers(window: *c.GLFWwindow) void {
    return c.glfwSwapBuffers(window);
}

pub fn PollEvents() void {
    return c.glfwPollEvents();
}
