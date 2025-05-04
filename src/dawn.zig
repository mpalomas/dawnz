const std = @import("std");

const cdawn = @cImport({
    @cDefine("WGPU_SHARED_LIBRARY", {});
    @cInclude("dawn/webgpu.h");
});

pub fn init() !void {
    return;
}

var wgpuInstance: cdawn.WGPUInstance = null;
pub fn createInstance() !void {
    wgpuInstance = cdawn.wgpuCreateInstance(null);
    if (wgpuInstance == null) {
        return error.GpuInstanceCreationFailed;
    }
}
