const std = @import("std");

const cdawn = @cImport({
    @cDefine("WGPU_SHARED_LIBRARY", {});
    @cInclude("dawn/webgpu.h");
});

pub fn init() !void {
    return;
}

var wgpuInstance: cdawn.WGPUInstance = undefined;
pub fn createInstance() void {
    wgpuInstance = cdawn.wgpuCreateInstance(null);
    std.debug.assert(wgpuInstance != null);
    std.debug.print("wgpuCreateInstance called and returned an instance\n", .{});
}
