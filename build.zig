const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const target_os_tag = target.result.os.tag;

    const optimize = b.standardOptimizeOption(.{});

    const shared = b.option(bool, "shared", "Build and consume Google Dawn as a shared library") orelse true;

    if (shared == false) {
        return error.StaticBuildNotYetSupported;
    }

    const dawn_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    var dawn_shared_name: [:0]const u8 = undefined;
    var dawn_static_name: [:0]const u8 = undefined;
    var dawn_lib_base_path: [:0]const u8 = undefined;

    switch (target_os_tag) {
        .linux => {
            dawn_shared_name = "libdawn.so";
            dawn_static_name = "libdawn.a";
            dawn_lib_base_path = "dawn/linux-x86_64";
        },
        .macos => {
            dawn_shared_name = "libdawn.dylib";
            dawn_static_name = "libdawn.a";
            dawn_lib_base_path = "dawn/macos-aarch64";
        },
        .windows => {
            dawn_shared_name = "dawn.dll";
            dawn_static_name = "dawn.lib";
            dawn_lib_base_path = "dawn/windows-x86_64";
        },
        else => {
            return error.OsNotSupported;
        },
    }

    var lib_path_buffer: [256]u8 = undefined;
    const dawn_lib_path = try std.fmt.bufPrint(&lib_path_buffer, "{s}/{s}", .{ dawn_lib_base_path, if (shared) "shared" else "static" });

    var path_buffer: [256]u8 = undefined;
    const dawn_path = try std.fmt.bufPrint(&path_buffer, "{s}/{s}", .{ dawn_lib_path, if (shared) dawn_shared_name else dawn_static_name });

    const dawn_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "dawnz",
        .root_module = dawn_mod,
    });
    dawn_lib.addIncludePath(b.path("dawn/include"));
    dawn_lib.linkLibC();
    dawn_lib.installHeadersDirectory(b.path("dawn/include/dawn"), "dawn", .{});

    if (shared) {
        dawn_lib.addLibraryPath(b.path(dawn_lib_path));
        dawn_lib.linkSystemLibrary("dawn");
        b.addNamedLazyPath("dawn_shared_library", b.path(dawn_path));
    } else {}
    // b.installBinFile(dawn_path, dawn_lib_name);
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
