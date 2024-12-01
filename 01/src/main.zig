const std = @import("std");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buffer: [1024]u8 = undefined;

    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(allocator.deinit() == .ok);

    const alloc = allocator.allocator();

    const List = std.ArrayList(u32);
    var left = List.init(alloc);
    defer left.deinit();
    var right = List.init(alloc);
    defer right.deinit();

    var counter = false;

    while (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var words = std.mem.splitScalar(u8, line, ' ');
        while (words.next()) |word| {
            counter = !counter;
            const number = try std.fmt.parseUnsigned(u32, word, 10);
            switch (counter) {
                true => try left.append(number),
                false => try right.append(number),
            }
        }
    }

    std.mem.sort(u32, left.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, right.items, {}, comptime std.sort.asc(u32));

    var difference: u32 = 0;

    for (left.items, right.items) |l, r| {
        difference += std.math.sub(u32, l, r) catch r - l;
    }

    try stdout.print("{}\n", .{difference});

    const max_index = std.mem.max(u32, left.items);
    var counts = try List.initCapacity(alloc, max_index + 1);
    defer counts.deinit();

    try counts.resize(max_index + 1);

    for (counts.items) |*item| {
        item.* = 0;
    }
    for (right.items) |item| {
        if (counts.items.len > item) {
            counts.items[item] += 1;
        }
    }

    var similarity: u32 = 0;
    for (left.items) |item| {
        similarity += counts.items[item] * item;
    }

    try stdout.print("{}\n", .{similarity});
}
