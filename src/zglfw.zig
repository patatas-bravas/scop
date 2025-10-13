const c = @cImport(@cInclude("GLFW/glfw3.h"));

pub const FALSE = c.GLFW_FALSE;
pub const TRUE = c.GLFW_TRUE;
pub const CONTEXT_VERSION_MAJOR = c.GLFW_CONTEXT_VERSION_MAJOR;
pub const CONTEXT_VERSION_MINOR = c.GLFW_CONTEXT_VERSION_MINOR;
pub const OPENGL_PROFILE = c.GLFW_OPENGL_PROFILE;
pub const OPENGL_CORE_PROFILE = c.GLFW_OPENGL_CORE_PROFILE;

pub const Window = c.GLFWwindow;

pub const GetProcAddress = c.glfwGetProcAddress;

pub fn init() c_int {
    return c.glfwInit();
}

pub fn windowHint(hint: c_int, value: c_int) void {
    return c.glfwWindowHint(hint, value);
}

pub fn terminate() void {
    return c.glfwTerminate();
}

pub fn createWindow(width: c_int, height: c_int, title: [*:0]const u8, monitor: ?*c.GLFWmonitor, share: ?*c.GLFWwindow) ?*c.GLFWwindow {
    return c.glfwCreateWindow(width, height, title, monitor, share);
}

pub fn destroyWindow(window: *c.GLFWwindow) void {
    return c.glfwDestroyWindow(window);
}

pub fn makeContextCurrent(window: *c.GLFWwindow) void {
    return c.glfwMakeContextCurrent(window);
}

pub fn windowShouldClose(window: *c.GLFWwindow) c_int {
    return c.glfwWindowShouldClose(window);
}

pub fn swapBuffers(window: *c.GLFWwindow) void {
    return c.glfwSwapBuffers(window);
}

pub fn pollEvents() void {
    return c.glfwPollEvents();
}
