const std = @import("std");
const print = std.debug.print;

const WordCount = struct {
    count: u32,
    word: []const u8,
};

fn WordCountLessThan(_: void, lhs: WordCount, rhs: WordCount) bool {
    return lhs.count < rhs.count;
}

const Query = struct {
    top: u32,
    keywords: std.ArrayList([]const u8),
    exclude_dirs: std.ArrayList([]const u8),
};
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = arena.deinit();
    const a = arena.allocator();

    var args = try std.process.argsWithAllocator(a);
    const ParseState = enum { TOP_ARG, DIR_ARG, KEYWORD };
    var state: ParseState = ParseState.KEYWORD;
    var query: Query = .{ .top = 0, .keywords = std.ArrayList([]const u8).empty, .exclude_dirs = std.ArrayList([]const u8).empty };

    while (args.next()) |arg| {
        switch (state) {
            ParseState.TOP_ARG => {
                query.top = try std.fmt.parseInt(u32, arg, 10);
                state = ParseState.KEYWORD;
            },
            ParseState.DIR_ARG => {
                try query.exclude_dirs.append(a, arg);
                state = ParseState.KEYWORD;
            },
            ParseState.KEYWORD => {
                if (std.mem.eql(u8, arg, "--top")) {
                    state = ParseState.TOP_ARG;
                } else if (std.mem.eql(u8, arg, "--exclude-dir")) {
                    state = ParseState.DIR_ARG;
                } else {
                    try query.keywords.append(a, arg);
                }
            },
        }
    }

    print("CLI Args {any}\n", .{query});

    const file_name = "README.md";
    const cwd = std.fs.cwd();
    var dir = try cwd.openDir(".", .{ .iterate = true });
    var cwd_it = try dir.walk(a);
    while (cwd_it.next() catch null) |d| {
        print("{s} {any}", .{ d.basename, d.kind });
    }

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
        print("{s} {d}\n", .{ i.word, i.count });
        start -= 1;
    }
}

// TODO:
// Make the dir walk recursive
// make the file reading multi threaded
// actually use the parsed args
