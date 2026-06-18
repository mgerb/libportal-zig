const std = @import("std");
const libportal = @import("libportal");

pub fn main() void {
    const sandboxed = libportal.xdp_portal_running_under_sandbox() != 0;
    std.debug.print("hello from libportal-zig\nrunning under sandbox: {}\n", .{sandboxed});
}
