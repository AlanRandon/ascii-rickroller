const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdout = std.io.getStdOut();

    var fbs = std.io.fixedBufferStream(@embedFile("frames.dat.xz"));
    var dcp = try std.compress.xz.decompress(allocator, fbs.reader());
    defer dcp.deinit();

    var frames = std.ArrayList([]u8).init(allocator);
    while (try dcp.reader().readUntilDelimiterOrEofAlloc(allocator, 0, 10_000)) |buf| {
        try frames.append(buf);
    }

    var child = std.process.Child.init(&.{ "aplay", "./never-gonna-give-you-up.wav" }, allocator);
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;
    try child.spawn();

    for (frames.items) |frame| {
        try stdout.writeAll("\u{001B}[H");
        try stdout.writeAll(frame);
        std.Thread.sleep(80 * std.time.ns_per_ms);
    }
}
