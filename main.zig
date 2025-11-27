const std = @import("std");
const lib = @import("lib/lib.zig");
pub fn main() void {
    lib.print_hello("hello world\n");
}
