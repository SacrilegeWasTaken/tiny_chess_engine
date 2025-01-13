const std = @import("std");
const fileboard = @import("board.zig");
const Board = fileboard.Board;
const Move = fileboard.Move;

pub const Engine = struct {
    board:      Board,
    checkw:     bool,
    checkb:     bool,
    checkm:     bool,
    movhist:    std.ArrayList([]const u8),
};
