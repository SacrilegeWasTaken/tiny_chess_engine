const fileengine = @import("../engine/engine.zig");
const std = @import("std");
const Engine = fileengine.Engine;
const EngineError = fileengine.EngineError;
const Cell = @import("../engine/board.zig").Cell;


pub const ChessCLIGame = struct {
    engine: *Engine,

    const Self = @This();
    const printBlackBoard = printBoard;

    pub fn startGame(self: *Self, timer: ?u64) !void {
        if(timer != null) {
            self.engine.setTimer(timer.?);
            try self.engine.startTimer();
        }

        // gameloop
        var move_cnt: u32 = 0;
        while(true) : (move_cnt += 1) {
            if(self.engine.curturn == .white) {
                self.printWhiteBoard();
            } else {
                self.printBlackBoard();
            }

            // get move
            const user_input = try Self.inputMoveNoValidate();
            try self.engine.inputMove(user_input, true);
        }
    }

    pub fn init(allocator: std.mem.Allocator) !Self {
       return Self {
           .engine = try Engine.init(allocator)
       };
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) !void {
        Engine.deinit(self.engine, allocator);
    }


    fn printBoard(self: *Self) void {
        const stdout_file = std.io.getStdOut().writer();
        var bw = std.io.bufferedWriter(stdout_file);
        const stdout = bw.writer();
        for (&self.engine.board.board, 1..9) |*row, i| {
            stdout.print("{d} ", .{i}) catch unreachable;
            for (row) |*cell| {
                if (cell.piece == null) {
                    stdout.print("▢ ", .{}) catch unreachable;
                } else {
                    cell.piece.?.print();
                }
            }
            stdout.print("\n", .{}) catch unreachable;
        }
        stdout.print("/ a b c d e f g h\n", .{}) catch unreachable;
    }
    /// # Algorithm
    /// I used 9 as counter instead of 8 because of integer overflow exeption.
    /// `while (i >= 1) : (i -= 1)` this syntax do decremention after iteration,
    /// so when `i == 0`, function tries to make unsigned type negative.
    fn printWhiteBoard(self: *Self) void {
        const stdout_file = std.io.getStdOut().writer();
        var bw = std.io.bufferedWriter(stdout_file);
        const stdout = bw.writer();
        var i: u8 = 9;
        while (i > 1) : (i -= 1) {
            stdout.print("{d} ", .{i - 1}) catch unreachable;
            const row: *[8]Cell = &self.engine.board.board[i - 2];
            for (row) |*cell| {
                if (cell.piece == null) {
                    stdout.print("▢ ", .{}) catch unreachable;
                } else {
                    cell.piece.?.print();
                }
            }
            stdout.print("\n", .{}) catch unreachable;
        }
        stdout.print("/ a b c d e f g h\n", .{}) catch unreachable;
    }

    fn inputMoveNoValidate() ![]const u8 {
        const stdin = std.io.getStdIn().reader();
        var buffer: [80]u8 = undefined;
        const data: []u8 = try stdin.readUntilDelimiter(&buffer, '\n');
        return data;
    }

    fn printReturns() void {
        const stdout_file = std.io.getStdOut().writer();
        var bw = std.io.bufferedWriter(stdout_file);
        const stdout = bw.writer();

        inline for(0..70) |_| {
            stdout.print("\r", .{}) catch unreachable;
        }
    }
};
