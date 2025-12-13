const std = @import("std");
const vk = @import("vulkan");
const glfw = @import("glfw");

pub fn main() !void {
    std.debug.print("Start App", .{});

    if (glfw.glfwInit() != glfw.GLFW_TRUE) return error.InitFail;
    glfw.glfwTerminate();
}