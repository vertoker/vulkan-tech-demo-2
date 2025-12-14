const std = @import("std");
const engine = @import("engine.zig");
const Window = engine.Window;

pub fn main() !void {
    std.debug.print("Start App\n", .{});

    const window = try Window.create(800, 600, "vulkan-tech-demo-2");
    defer window.destroy();

    var frames_counter: u64 = 0;
    while (!window.shouldClose()) {
        Window.pollEvents();
        frames_counter += 1;
        // std.debug.print("Frame {}\n", .{frames_counter});
    }
    std.debug.print("Lifetime frames {}\n", .{frames_counter});
}