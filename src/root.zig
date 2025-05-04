//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

pub const cdawn = @cImport({
    @cInclude("dawn/webgpu.h");
});

test "dawn instance creation" {
    const wgpuInstance: cdawn.WGPUInstance = cdawn.wgpuCreateInstance(null);
    try testing.expect(wgpuInstance != null);
}
