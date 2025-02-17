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
            var buffer: [1024]u8 = undefined;
            var user_input = Self.inputMoveNoValidate(&buffer);
            try self.engine.inputMove(&user_input, true);
        }
    }

    pub fn init(allocator: std.mem.Allocator) !Self {
       return Self {
           .engine = try Engine.init(allocator)
       };
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        Engine.deinit(self.engine, allocator);
    }


    fn printBoard(self: *Self) void {
        for (&self.engine.board.board, 1..9) |*row, i| {
            std.debug.print("{d} ", .{i});
            for (row) |*cell| {
                if (cell.piece == null) {
                    std.debug.print("▢ ", .{});
                } else {
                    cell.piece.?.print();
                }
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("/ a b c d e f g h\n", .{});
    }
    /// # Algorithm
    /// I used 9 as counter instead of 8 because of integer overflow exeption.
    /// `while (i >= 1) : (i -= 1)` this syntax do decremention after iteration,
    /// so when `i == 0`, function tries to make unsigned type negative.
    fn printWhiteBoard(self: *Self) void {
        var i: u8 = 9;
        while (i > 1) : (i -= 1) {
            std.debug.print("{d} ", .{i - 1});
            const row: *[8]Cell = &self.engine.board.board[i - 2];
            for (row) |*cell| {
                if (cell.piece == null) {
                    std.debug.print("▢ ", .{});
                } else {
                    cell.piece.?.print();
                }
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("/ a b c d e f g h\n", .{});
    }

    fn inputMoveNoValidate(buffer: []u8) []const u8 {
        const stdin = std.io.getStdIn().reader();
        var output: []u8 = undefined;
        while (true) {
            output = stdin.readUntilDelimiter(buffer, '\n') catch {
                std.debug.print("Something went wrong with the input, try again!", .{});
                continue;
            };
            break;
        }
        return output;
    }

    fn printReturns() void {
        inline for(0..70) |_| {
            std.debug.print("\r", .{});
        }
    }
};
