const fileengine = @import("../engine/engine.zig");
const std = @import("std");
const Engine = fileengine.Engine;
const EngineError = fileengine.EngineError;
const Cell = @import("../engine/board.zig").Cell;


pub const ChessCLIGame = struct {
    engine: *Engine,

    const Self = @This();
    const printBlackBoard = printBoard;



    /// Starts game, initializing timer if timer value is set.\
    /// Then running a gameloop with board printing and getting moves.
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
            while (true) {
                var buffer: [8]u8 = undefined;
                var user_input = Self.inputMoveNoValidate(&buffer);
                self.engine.inputMove(&user_input, true) catch continue;
                break;
            }
        }
    }



    /// Initializing `ChessCLIGame` struct.
    pub fn init(allocator: std.mem.Allocator) !Self {
       return Self {
           .engine = try Engine.init(allocator)
       };
    }



    /// Deinitializing `ChessCLIGame` struct.
    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        Engine.deinit(self.engine, allocator);
    }



    /// # Print the board for black side
    /// # Algorithm
    /// I used 9 as counter instead of 8 because of integer overflow exeption.
    /// `while (i >= 1) : (i -= 1)` this syntax do decremention after iteration,
    /// so when `i == 0`, function tries to make unsigned type negative.
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



    /// # Print the board for white side
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



    /// Getting move without validation
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
};
