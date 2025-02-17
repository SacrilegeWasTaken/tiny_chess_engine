const std = @import("std");
const fileboard = @import("board.zig");
const Board = fileboard.Board;
const Move = fileboard.Move;
const Pos = fileboard.Pos;
const Color = @import("pieces.zig").Color;

pub const EngineError = error {
    AllocationError,
    InvalidInput,
    IllegalMove,
    TimerNotSet,
    NoSupportedClock,
};


pub const Engine = struct {
    board:      Board,
    gamet:      ?u64,
    timerw:     ?std.time.Timer,
    timerb:     ?std.time.Timer,
    wtsum:      ?u64,
    btsum:      ?u64,
    checkw:     bool,
    checkb:     bool,
    checkm:     bool,
    curturn:    Color,
    movhist:    std.ArrayList([]const u8),


    const Self = @This();



    pub fn init(allocator: std.mem.Allocator) EngineError!*Self {
        const movhist = std.ArrayList([]const u8).init(allocator);
        var engine = allocator.create(Self) catch return error.AllocationError;

        engine.board = Board.create();
        engine.movhist = movhist;
        engine.curturn = .white;
        engine.checkw = false;
        engine.checkb = false;
        engine.checkm = false;
        engine.timerw = null;
        engine.timerb = null;
        engine.wtsum = null;
        engine.btsum = null;
        engine.gamet = null;
        return engine;
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        self.movhist.deinit();
        allocator.destroy(self);
    }

    pub fn setTimer(self: *Self, secs: u64) void {
        self.gamet = secs * std.time.ns_per_s;
        self.wtsum = 0;
        self.btsum = 0;
    }

    pub fn startTimer(self: *Self) EngineError!void {
        if(self.gamet == null) return error.TimerNotSet;
        self.timerw = std.time.Timer.start() catch return error.NoSupportedClock;
    }

    pub fn switchTimer(self: *Self) EngineError!void{
        if(self.timerw == null) {
            self.btsum += self.timerb.?.read();
            self.timerw = std.time.Timer.start();
        } else {
            self.wtsum += self.timerw.?.read();
            self.timerb = std.time.Timer.start();
        }
    }

    /// Works for current turn
    pub fn checkTimeIsUp(self: *Self) EngineError!bool {
        if(self.gamet == null or self.wtsum == null or self.btsum == null)
            return error.TimerNotSet;
        if(self.curturn == .white) {
            return self.wtsum >= self.gamet;
        } else {
            return self.btsum >= self.gamet;
        }
    }

    /// Inputing move into Engine. Switches the side if move is ok.
    /// - `input` is 4 byte length string slice containing input move in format `d2d4` for example.
    /// - `debug` is a marker for debug stdout logging.
    pub fn inputMove(self: *Self, input: *[]const u8, comptime debug: bool) EngineError!void {
        if (input.len != 4) {
            if(debug) Self.inputErrorMsg();
            return error.InvalidInput;
        } else {
            const l1 = Self.isBoardLetter(input.*[0]);
            const d2 = Self.isBoardDigit(input.*[1]);
            const l3 = Self.isBoardLetter(input.*[2]);
            const d4 = Self.isBoardDigit(input.*[3]);

            if (l1 and d2 and l3 and d4) {
                const move = Self.parseMove(input.*);
                if(!self.basicMoveValidation(move, self.curturn)) return error.InvalidInput;
                self.board.movePiece(move) catch |err| return err;
                if(self.curturn == .white) self.curturn = .black else self.curturn = .white;
            } else {
                if(debug) Self.inputErrorMsg();
                return error.InvalidInput;
            }
        }
    }

    fn parseMove(move: []const u8) Move {
        var src: Pos = undefined;
        var dst: Pos = undefined;
        // 97 is ASCII value for 'a' so we converting it to index this way
        // 49 is ASCII value for '1' so we converting it to index this way
        // UTF-8 and ASCII are back-compatible so that I've been counting in ASCII
        for (move, 0..4) |char, i| {
            if (i % 2 == 0) {
                if (i == 0) src.x = char - 97;
                if (i == 2) dst.x = char - 97;
            } else {
                if (i == 1) src.y = char - 49;
                if (i == 3) dst.y = char - 49;
            }
        }
        return .{ .src = src, .dst = dst };
    }

    inline fn isBoardDigit(char: u8) bool {
        const digits = "12345678";
        return std.mem.indexOfScalar(u8, digits, char) != null;
    }

    inline fn isBoardLetter(char: u8) bool {
        const letters = "abcdefgh";
        return std.mem.indexOfScalar(u8, letters, char) != null;
    }

    inline fn inputErrorMsg() void {
        std.debug.print("Unexpected input. Please send move in format: e2e4\nTry again: ", .{});
    }

    fn basicMoveValidation(self: *Self, move: Move, color: Color) bool {
        const moving_piece = &self.board.board[move.src.y][move.src.x].piece;
        const destin_square = &self.board.board[move.dst.y][move.dst.x].piece;
        if(moving_piece.* == null) return false;
        if(moving_piece.*.?.color != color) return false;
        if(destin_square.* == null) return true;
        if(destin_square.*) |*piece| {
            if(piece.color == color) return false;
        }
        return true;
    }
};
