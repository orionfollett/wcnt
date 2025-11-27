const std = @import("std");

pub fn main() !void {
    var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = aa.deinit();
    const a = aa.allocator();

    const file_name = "README.md";
    const f = try std.fs.cwd().openFile(file_name, .{});
    defer f.close();
    const s = try f.readToEndAlloc(a, 1000000000);

    var word_counts = std.hash_map.StringHashMap(u32).init(a);
    var it = std.mem.tokenizeAny(u8, s, ".,;:!@#$%^&*()-+ /|{}[]\n\t=`\"\'");
    while (it.next()) |token| {
        const result = try word_counts.getOrPut(token);
        if (!result.found_existing) {
            result.value_ptr.* = 1;
        } else {
            result.value_ptr.* += 1;
        }
    }
    var nit = word_counts.iterator();
    while (nit.next()) |item| {
        std.debug.print("{s} {d}\n", .{ item.key_ptr.*, item.value_ptr.* });
    }
}
