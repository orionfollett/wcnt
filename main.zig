const std = @import("std");

const WordCount = struct {
    count: u32,
    word: []const u8,
};
fn WordCountLessThan(_: void, lhs: WordCount, rhs: WordCount) bool {
    return lhs.count < rhs.count;
}

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

    var word_count_list = try std.array_list.Aligned(WordCount, null).initCapacity(a, word_counts.capacity() * @sizeOf(WordCount));
    var nit = word_counts.iterator();
    while (nit.next()) |item| {
        try word_count_list.append(a, .{ .count = item.value_ptr.*, .word = item.key_ptr.* });
    }

    std.sort.pdq(
        WordCount,
        word_count_list.items,
        {},
        WordCountLessThan,
    );

    const end = @max(0, word_count_list.items.len - 10);
    var start = word_count_list.items.len - 1;
    while (start >= end) {
        const i = word_count_list.items[start];
        std.debug.print("{s} {d}\n", .{ i.word, i.count });
        start -= 1;
    }
}
