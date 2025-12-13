const std = @import("std");
const builtin = @import("builtin");

const zig_version = std.SemanticVersion{
    .major = 0,
    .minor = 15,
    .patch = 2,
};

comptime {
    const zig_version_eq = zig_version.major == builtin.zig_version.major and
        zig_version.minor == builtin.zig_version.minor and
        (zig_version.patch == builtin.zig_version.patch);

    if (!zig_version_eq) {
        @compileError(std.fmt.comptimePrint(
            "unsupported zig version: expected {f}, found {f}",
            .{ zig_version, builtin.zig_version },
        ));
    }
}

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