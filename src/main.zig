const std = @import("std");
const vk = @import("vulkan");
const glfw = @import("glfw");

pub fn main() !void {
    std.debug.print("Start App\n", .{});

    if (glfw.glfwInit() != glfw.GLFW_TRUE) return error.InitFail;
    defer glfw.glfwTerminate();

    const handle = glfw.glfwCreateWindow(800, 600, "hello", null, null)
        orelse return error.WindowCreateFail;
    defer glfw.glfwDestroyWindow(handle);

    var frames_counter: u64 = 0;
    while (glfw.glfwWindowShouldClose(handle) != glfw.GLFW_TRUE) {
        glfw.glfwPollEvents();
        frames_counter += 1;
        // std.debug.print("Frame {}\n", .{frames_counter});
    }
    std.debug.print("Lifetime frames {}\n", .{frames_counter});
}