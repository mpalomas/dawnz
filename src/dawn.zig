const std = @import("std");

const cdawn = @cImport({
    @cDefine("WGPU_SHARED_LIBRARY", {});
    @cInclude("dawn/webgpu.h");
});

var wgpuInstance: cdawn.WGPUInstance = undefined;
pub fn createInstance() void {
    wgpuInstance = cdawn.wgpuCreateInstance(null);
    std.debug.assert(wgpuInstance != null);
}
