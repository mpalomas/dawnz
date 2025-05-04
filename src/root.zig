//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

pub const dawn = @import("dawn.zig");

pub export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try dawn.createInstance();
    try testing.expect(true);
}
