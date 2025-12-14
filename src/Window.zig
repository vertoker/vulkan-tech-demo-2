const std = @import("std");
const vk = @import("vulkan");

const glfw = @import("glfw");
// const glfw = @cImport({ @cInclude("GLFW/glfw3.h"); });

const Error = error {
    InitFail,
    WindowCreateFail,
    SurfaceCreateFail,
};

const Self = @This();

handle: *glfw.GLFWwindow,

pub fn create(width: u32, height: u32, app_name: [*:0]const u8) Error!Self {
    const Callback = struct {
        fn callback(code: c_int, message: [*c]const u8) callconv(.c) void {
            std.log.warn("glfw: {}: {s}", .{code, message});
        }
    };

    _ = glfw.glfwSetErrorCallback(Callback.callback);

    if (glfw.glfwInit() != glfw.GLFW_TRUE) return Error.InitFail;

    glfw.glfwWindowHint(glfw.GLFW_CLIENT_API, glfw.GLFW_NO_API);

    const handle = glfw.glfwCreateWindow(@intCast(width), @intCast(height),
        app_name, null, null) orelse {
            glfw.glfwTerminate();
            return Error.WindowCreateFail;
        };

    return Self {
        .handle = handle,
    };
}
pub fn destroy(self: *const Self) void {
    glfw.glfwDestroyWindow(self.handle);
    glfw.glfwTerminate();
}

pub fn shouldClose(self: *const Self) bool {
    return glfw.glfwWindowShouldClose(self.handle) == glfw.GLFW_TRUE;
}
pub fn pollEvents() void {
    glfw.glfwPollEvents();
}

// pub fn createSurface(self: *const Self, instance: vk.VkInstance) Error!vk.VkSurfaceKHR {
//     var surface: vk.VkSurfaceKHR = undefined;
//     if (glfw.glfwcreatewin)
// }