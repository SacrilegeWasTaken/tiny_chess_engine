const std = @import("std");
const Chess = @import("game/cli.zig").ChessCLIGame;

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
