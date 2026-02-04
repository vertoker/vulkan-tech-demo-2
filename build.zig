const std = @import("std");
const builtin = @import("builtin");

const zig_version = std.SemanticVersion{
    .major = 0,
    .minor = 16,
    .patch = 0,
};

comptime {
    const zig_version_eq = zig_version.major == builtin.zig_version.major and
        zig_version.minor == builtin.zig_version.minor and zig_version.patch == builtin.zig_version.patch;

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

    // Modules

    const vulkan_module = createVulkanModule(b, target, optimize);
    const glfw_module = createGlfwModule(b, target, optimize);

    const imports = [_]std.Build.Module.Import {
        .{ .name = "vulkan", .module = vulkan_module },
        .{ .name = "glfw", .module = glfw_module },
    };

    // Executable

    const exe = b.addExecutable(.{
        .name = app_name,
        .root_module = b.createModule(.{
            .root_source_file = b.path(root_source_file),
            .link_libc = true,
            .target = target,
            .optimize = optimize,
            .imports = &imports,
        }),
        // TODO: Remove this once x86_64 is stable
        .use_llvm = true,
    });

    // linkGlfwModule(b, exe, target, optimize);

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

fn createModule(b: *std.Build,
    name: []const u8,
    path: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Module {
    const module = b.addModule(name, .{
        .root_source_file = b.path(path),
        .target = target,
        .optimize = optimize,
    });
    return module;
}

fn createVulkanModule(b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
// ) void {
) *std.Build.Module {
    const vulkan_headers = b.dependency("vulkan_headers", .{
        .target = target,
        .optimize = optimize,
    });
    const registry = vulkan_headers.path("registry/vk.xml");

    const vulkan = b.dependency("vulkan_zig", .{.registry = registry});
    const module = vulkan.module("vulkan-zig");

    return module;
}

fn createGlfwModule(b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Module {
    // GLFW for work must be build with CMake, better use custom Zig build script (aycb)
    // https://ziggit.dev/t/best-way-to-combine-zig-and-cmake-projects/7466
    // This approved by Andrew Kelley (author of Zig) and Aleksey Kladov (TigerBeetle maintainer)
    // (actually I can use https://github.com/Batres3/zlfw)

    const glfw = b.dependency("glfw", .{
        .target = target,
        .optimize = optimize,
        // Additional options here
    });
    const step = b.addTranslateC(.{
        .root_source_file = glfw.path("include/GLFW/glfw3.h"),
        .optimize = .ReleaseFast,
        .target = target,
        .link_libc = true,
    });
    step.defineCMacro("GLFW_INCLUDE_NONE", null);
    // step.defineCMacro("GLFW_INCLUDE_VULKAN", null);
    step.addIncludePath(glfw.path("include/"));

    const module = step.createModule();
    module.linkLibrary(glfw.artifact("glfw"));
    return module;

    // actually based on this
    // https://github.com/ashpil/moonshine/blob/0331657460af59c336dd9f31a21aa3b7315ec17b/build.zig#L602
}