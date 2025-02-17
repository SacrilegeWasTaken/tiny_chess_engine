const std = @import("std");
const Chess = @import("game/cli.zig").ChessCLIGame;

pub const std_options = .{
    // Set the log level to info
    .log_level = .debug,
};

pub fn main() !void {
    // Creating allocator and deinitializing it by defer so all memory leaks
    // will be displayed when programm ends.

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var chess = try Chess.init(allocator);
    defer chess.deinit(allocator);


    try chess.startGame(null);
}
