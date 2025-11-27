const std = @import("std");

pub fn print_hello(comptime msg: []const u8) void {
    std.debug.print(msg, .{});
}
