const std = @import("std");
// const engine = @import("engine.zig");

pub fn main() !void {
    std.debug.print("Start App\n", .{});

    // const vkInstance = try engine.vulkan.create(false);
    // defer engine.vulkan.destroy(vkInstance);

    // const window = try engine.Window.create(800, 600, "vulkan-tech-demo-2");
    // defer window.destroy();

    // var frames_counter: u64 = 0;
    // while (!window.shouldClose()) {
        // engine.Window.pollEvents();
        // frames_counter += 1;
        // std.debug.print("Frame {}\n", .{frames_counter});
    // }
    // std.debug.print("Lifetime frames {}\n", .{frames_counter});
}