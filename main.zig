const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const sa = std.posix.Sigaction{
        .handler = .{
            .handler = std.posix.SIG.IGN,
        },
        .mask = std.posix.empty_sigset,
        .flags = 0,
    };

    std.posix.sigaction(std.posix.SIG.INT, &sa, null); // CTRL+C
    std.posix.sigaction(std.posix.SIG.STOP, &sa, null); // CTRL+Z
    std.posix.sigaction(std.posix.SIG.QUIT, &sa, null); // CTRL+\

    const stdout = std.io.getStdOut();

    var fbs = std.io.fixedBufferStream(@embedFile("frames.dat.xz"));
    var dcp = try std.compress.xz.decompress(allocator, fbs.reader());
    defer dcp.deinit();

    var frames = std.ArrayList([]u8).init(allocator);
    while (try dcp.reader().readUntilDelimiterOrEofAlloc(allocator, 0, 10_000)) |buf| {
        try frames.append(buf);
    }

    const pid = try std.posix.fork();
    if (pid == 0) {
        _ = std.os.linux.setsid();
        return std.process.execv(allocator, &.{ "aplay", "./never-gonna-give-you-up.wav", "-q" });
    }

    for (frames.items) |frame| {
        try stdout.writeAll("\u{001B}[H");
        try stdout.writeAll(frame);
        std.Thread.sleep(80 * std.time.ns_per_ms);
    }
}
