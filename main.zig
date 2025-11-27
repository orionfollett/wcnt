const std = @import("std");

pub fn main() !void {
    var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = aa.deinit();
    var a = aa.allocator();

    const file_name = "README.md";

    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();

    const s = try f.readToEndAlloc(a, 1000000000);
    defer a.free(s);

    std.debug.print("{s}", .{s});
}
