const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    // A compile error stack trace of 10 is arbitrary in size but helps with debugging (TigerBeetle)
    b.reference_trace = 10;

    const app_name = "vulkan-tech-demo-2";
    const root_source_file = "src/main.zig";
    const run_step = b.step("run", "Run the app");
    const tests_step = b.step("tests", "Run tests");

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Executable

    const exe = b.addExecutable(.{
        .name = app_name,
        .root_module = b.createModule(.{
            .root_source_file = b.path(root_source_file),
            // .link_libc = true,
            .target = target,
            .optimize = optimize,
            // .imports = &imports,
        }),
    });

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());
    run_step.dependOn(&run_cmd.step);

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // Tests

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);
    tests_step.dependOn(&run_exe_tests.step);
}