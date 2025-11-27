const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.raw_c_allocator;
    const file_name = "README.md";

    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();

    const s = try f.readToEndAlloc(allocator, 1000000000);
    defer allocator.free(s);

    std.debug.print("{s}", .{s});
}
