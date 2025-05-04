const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const target_os_tag = target.result.os.tag;

    const optimize = b.standardOptimizeOption(.{});

    const dawn_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const dawn_path = switch (target_os_tag) {
        .linux => "dawn/linux-x86_64/libdawn.so",
        .macos => "dawn/macos-aarch64/libdawn.dylib",
        .windows => "dawn/windows-x86_64/dawn.dll",
        else => unreachable,
    };

    const dawn_lib_path = switch (target_os_tag) {
        .linux => "dawn/linux-x86_64",
        .macos => "dawn/macos-aarch64",
        .windows => "dawn/windows-x86_64",
        else => unreachable,
    };

    const dawn_lib_name = switch (target_os_tag) {
        .linux => "libdawn.so",
        .macos => "libdawn.dylib",
        .windows => "dawn.dll",
        else => unreachable,
    };

    _ = dawn_lib_name;

    const dawn_static_name = switch (target_os_tag) {
        .linux => "libdawn.a",
        .macos => "libdawn.a",
        .windows => "dawn.lib",
        else => unreachable,
    };

    _ = dawn_static_name;

    const dawn_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "dawnz",
        .root_module = dawn_mod,
    });
    dawn_lib.addIncludePath(b.path("dawn/include"));
    dawn_lib.linkLibC();
    dawn_lib.installHeadersDirectory(b.path("dawn/include/dawn"), "dawn", .{});
    dawn_lib.addLibraryPath(b.path(dawn_lib_path));
    dawn_lib.linkSystemLibrary("dawn");

    // b.installBinFile(dawn_path, dawn_lib_name);
    b.addNamedLazyPath("dawn_shared_library", b.path(dawn_path));
    b.installArtifact(dawn_lib);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_module = dawn_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
