const module_board = @import("board.zig");
const std = @import("std");
const Move = module_board.Move;
const Board = module_board.Board;
const Pos = module_board.Pos;
/// Represents type of the piece.
pub const PType = enum {
    rook,
    king,
    pawn,
    queen,
    bishop,
    knight,
};
/// Represents color of the piece.
pub const Color = enum {
    white,
    black,
};
/// # Fields
/// - who -> represents type of the piece
/// - color -> represents color of the piece
pub const Piece = struct {
    who:    PType,
    color:  Color,
    moved:  bool,


    const Self = @This();


    /// # Checks movement validity for a piece.
    /// Returns *`true`* if move is valid, and false if it's illegal.
    pub fn moveChecked(self: *Self, board: *Board, move: Move) bool {
        switch(self.who) {
            .rook   => return self.rookMove(board, move),
            .king   => return self.kingMove(board, move),
            .pawn   => return self.pawnMove(board, move),
            .queen  => return self.queenMove(board, move),
            .bishop => return self.bishopMove(board, move),
            .knight => return self.knightMove(board, move),
        }
    }




    /// # Marking Attacked Cells as attacked.
    pub fn markAttackedCells(self: *Self, board: *Board, pos: Pos) void {
        switch(self.who) {
            .rook   => self.rookMarkAttackedCells(board, pos),
            .king   => self.kingMarkAttackedCells(board, pos),
            .pawn   => self.pawnMarkAttackedCells(board, pos),
            .queen  => self.queenMarkAttackedCells(board, pos),
            .bishop => self.bishopMarkAttackedCells(board, pos),
            .knight => self.knightMarkAttackedCells(board, pos),
        }
    }


    pub fn print(self: *Self) void {
        switch (self.who) {
            .pawn => {
                if (self.color == Color.white) {
                    std.debug.print("♟ ", .{});
                } else {
                    std.debug.print("♙ ", .{});
                }
            },
            .bishop => {
                if (self.color == Color.white) {
                    std.debug.print("♝ ", .{});
                } else {
                    std.debug.print("♗ ", .{});
                }
            },
            .knight => {
                if (self.color == Color.white) {
                    std.debug.print("♞ ", .{});
                } else {
                    std.debug.print("♘ ", .{});
                }
            },
            .king => {
                if (self.color == Color.white) {
                    std.debug.print("♚ ", .{});
                } else {
                    std.debug.print("♔ ", .{});
                }
            },
            .queen => {
                if (self.color == Color.white) {
                    std.debug.print("♛ ", .{});
                } else {
                    std.debug.print("♕ ", .{});
                }
            },
            .rook => {
                if (self.color == Color.white) {
                    std.debug.print("♜ ", .{});
                } else {
                    std.debug.print("♖ ", .{});
                }
            },
        }
    }


    /// Mark cells attacked by rook
    fn rookMarkAttackedCells(self: *Self, board: *Board, pos: Pos) void {
        self.markStraightCells(board, pos);
    }

    /// Mark cells attacked by king
    fn kingMarkAttackedCells(self: *Self, board: *Board, pos: Pos) void {
        const kingMoves = [_][2]i8{
            .{ 1, 0 }, .{ 1, 1 }, .{ 0, 1 }, .{ -1, 1 },
            .{ -1, 0 }, .{ -1, -1 }, .{ 0, -1 }, .{ 1, -1 },
        };

        for (kingMoves) |move| {
            const newX = @as(i16, pos.x) + @as(i16, move[0]);
            const newY = @as(i16, pos.y) + @as(i16, move[1]);

            if (newX >= 0 and newX <= 7 and newY >= 0 and newY <= 7) {
                var cell = &board.board[@intCast(newY)][@intCast(newX)];
                if (self.color == .white) cell.abw = true else cell.abb = true;
                if (cell.piece != null) break;
            }
        }
    }

    /// Mark cells attacked by pawn
    fn pawnMarkAttackedCells(self: *Self, board: *Board, pos: Pos) void {
        const direction = if (self.color == .white) -1 else 1;

        inline for ([_]i8{ -1, 1 }) |dx| {
            const newX = @as(i16, pos.x) + @as(i16, dx);
            const newY = @as(i16, pos.y) + @as(i16, direction);

            if (newX >= 0 and newX <= 7 and newY >= 0 and newY <= 7) {
                var cell = &board.board[@intCast(newY)][@intCast(newX)];
                if (self.color == .white) cell.abw = true else cell.abb = true;
                if (cell.piece != null) break;
            }
        }
    }

    /// Mark cells attacked by queen
    fn queenMarkAttackedCells(self: *Self, board: *Board, pos: Pos) void {
        self.markDiagonalCells(board, pos);
        self.markStraightCells(board, pos);
    }

    /// Mark cells attacked by bishop
    fn bishopMarkAttackedCells(self: *Self, board: *Board, pos: Pos) void {
        self.markDiagonalCells(board, pos);
    }
    /// Mark cells attacked by knight
    fn knightMarkAttackedCells(self: *Self, board: *Board, pos: Pos) void {
        const knightMoves = [_][2]i8{
            .{ 2, 1 }, .{ 2, -1 },
            .{ -2, 1 }, .{ -2, -1 },
            .{ 1, 2 }, .{ 1, -2 },
            .{ -1, 2 }, .{ -1, -2 },
        };

        inline for (knightMoves) |move| {
            const newX = @as(i16, pos.x) + @as(i16, move.dx);
            const newY = @as(i16, pos.y) + @as(i16, move.dy);

            if (newX >= 0 and newX <= 7 and newY >= 0 and newY <= 7) {
                var cell = &board.board[@intCast(newY)][@intCast(newX)];
                if (self.color == .white) cell.abw = true else cell.abb = true;
                if (cell.piece != null) break;
            }
        }
    }

    /// Mark diagonal cells
    fn markDiagonalCells(self: *Self, board: *Board, pos: Pos) void {
        inline for(0..2) |i| {
            inline for(0..2) |j| {
                const y_direction = if(i%2 == 0) 1 else -1;
                const x_direction = if(j%2 != 0) 1 else -1;

                var k = 1;
                while(true) : ( k += 1 ) {
                    const x: i16 = @as(i16, pos.x) + (@as(i16, @intCast(k)) * x_direction);
                    const y: i16 = @as(i16, pos.y) + (@as(i16, @intCast(k)) * y_direction);
                    if(x > 7 or x < 0 or y > 7 or y < 0) break;
                    const cell = board.board[@intCast(y)][@intCast(x)];
                    if (self.color == .white) cell.abw = true else cell.abb = true;
                    if (cell.piece != null) break;
                }
            }
        }
    }

    /// Mark straight cells
    fn markStraightCells(self: *Self, board: *Board, pos: Pos) void {
        // mark horizontal
        inline for (0..2) |i| {
            const x_direction = if (i == 0) 1 else -1;
            var k: i16 = 1;
            while (true) : (k += 1) {
                const x: i16 = @as(i16, pos.x) + (@as(i16, @intCast(k)) * x_direction);
                if (x > 7 or x < 0) break;
                const cell = board.board[pos.y][@intCast(x)];
                if (self.color == .white) cell.abw = true else cell.abb = true;
                if (cell.piece != null) break;
            }
        }
        // mark vertical
        inline for (0..2) |i| {
            const y_direction = if (i == 0) 1 else -1;
            var k: i16 = 1;
            while (true) : (k += 1) {
                const y: i16 = @as(i16, pos.y) + (@as(i16, @intCast(k)) * y_direction);
                if (y > 7 or y < 0) break;
                const cell = board.board[@intCast(y)][pos.x];
                if (self.color == .white) cell.abw = true else cell.abb = true;
                if (cell.piece != null) break;
            }
        }
    }





    /// Knight primary movement rule check.
    fn knightMove(self: *Self, board: *Board, move: Move) bool {
        const binding = Move.moveToDxDy(@constCast(&move));
        const dx = binding[0];
        const dy = binding[1];
        const basic =   @abs(dx) == 2 and @abs(dy) == 1 or
                        @abs(dx) == 1 and @abs(dy) == 2;


        if (!(basic and self.legalCells(board, move))) return false;
        Piece.movePieceRaw(board, move);
        return true;
    }

    /// Bishop primary movement rule check.
    fn bishopMove(self: *Self, board: *Board, move: Move) bool {
        const binding = Move.moveToDxDy(@constCast(&move));
        const dx = binding[0];
        const dy = binding[1];
        const basic = !(@abs(dx) != @abs(dy) or dx == 0 or dy == 0);


        if (!(basic and self.legalCells(board, move))) return false;


        // Determine direction
        const x_direction: i8 = if (dx > 0) 1 else -1;
        const y_direction: i8 = if (dy > 0) 1 else -1;
        // Check path
        const dxa: u8 = @abs(dx);
        for (1..dxa) |i| {
            if (dxa == 1) { Piece.movePieceRaw(board, move); return true; }
            const y: i9 = @as(i9, move.src.y) + (@as(i9, @intCast(i)) * y_direction);
            const x: i9 = @as(i9, move.src.x) + (@as(i9, @intCast(i)) * x_direction);
            const piece = &board.board[@intCast(y)][@intCast(x)].piece;
            if (piece.* != null) return false;
        }
        Piece.movePieceRaw(board, move);
        return true;
    }

    /// Queen primary movement rule check.
    fn queenMove(self: *Self, board: *Board, move: Move) bool {
        const binding = Move.moveToDxDy(@constCast(&move));
        const dx = binding[0];
        const dy = binding[1];
        const adx = @abs(dx);
        const ady = @abs(dy);
        const basic =   (adx == 0 and ady != 0) or  // vertical move
                        (adx != 0 and ady == 0) or  // horizonal move
                        (adx == ady);               // diagonal move

        std.log.debug("QUEEN MOVE -- dx: {d}, dy: {d}, basic: {any}", .{dx, dy, basic});

        if (!(basic and self.legalCells(board, move))) return false;


        // Determine direction for movement
        const x_direction: i8 = if (dx > 0) 1 else if (dx < 0) -1 else 0;
        const y_direction: i8 = if (dy > 0) 1 else if (dy < 0) -1 else 0;
        const distance = @max(adx, ady);

        // Check the path for obstruction
        for (1..distance) |i| {
            if (distance == 1) { Piece.movePieceRaw(board, move); return true; }
            const y: i9 = @as(i9, move.src.y) + (@as(i9, @intCast(i)) * y_direction);
            const x: i9 = @as(i9, move.src.x) + (@as(i9, @intCast(i)) * x_direction);
            const piece = &board.board[@intCast(y)][@intCast(x)].piece;
            if (piece.* != null) return false;
        }

        Piece.movePieceRaw(board, move);
        return true;
    }

    /// Not actually checking pawn, because of ultimate second algo.
    fn pawnMove(self: *Self, board: *Board, move: Move) bool {
        const xt: i8 = @intCast(move.dst.x);
        const xf: i8 = @intCast(move.src.x);
        const yt: i8 = @intCast(move.dst.y);
        const yf: i8 = @intCast(move.src.y);
        const dx = xt - xf;
        const dy = yt - yf;
        const side = &self.color;

        std.log.debug("PAWN MOVE -- xt: {d}, xf: {d}, yt: {d}, yf: {d}, dx: {d}, dy: {d}", .{xt, xf, yt, yf, dx, dy});

        if(!self.legalCells(board, move)) return false;

        // regular move
        if (dx == 0) {
            std.log.debug("PAWN MOVE -- regular move, color: {any}", .{side.*});
            if (side.* == .white) {
                if (dy == 1) {
                    // One square move forward
                    const res = board.board[@intCast(xt)][@intCast(yt)].piece == null;
                    if(res) Piece.movePieceRaw(board, move);
                    return res;
                } else if (yf == 1 and dy == 2) {
                    // Two square move from initial position
                    //
                    const res = board.board[@intCast(xf + 1)][@intCast(yf)].piece == null and
                                board.board[@intCast(xt)][@intCast(yt)].piece == null;
                    if(res) Piece.movePieceRaw(board, move);
                    return res;
                }
            } else { // Side is black
                if (dy == -1) {
                    // One square move backward
                    const res = board.board[@intCast(xt)][@intCast(yt)].piece == null;
                    if (res) Piece.movePieceRaw(board, move);
                    return res;
                } else if (yf == 6 and dy == -2) {
                    // Two square move from initial position
                    const res = board.board[@intCast(xf - 1)][@intCast(yf)].piece == null and
                                board.board[@intCast(xt)][@intCast(yt)].piece == null;
                    if(res) Piece.movePieceRaw(board, move);
                    return res;
                }
            }
        }

        // capture move (diagonal)
        if (@abs(dx) == 1) {
            std.log.debug("PAWN MOVE -- capture (diagonal) move, color: {any}", .{side.*});
            if (side.* == .white) {
                const res = dx == 1 and board.board[@intCast(xt)][@intCast(yt)].piece != null;
                if(res) Piece.movePieceRaw(board, move);
                return res;
            } else {
                const res = dx == -1 and board.board[@intCast(xt)][@intCast(yt)].piece != null;
                if(res) Piece.movePieceRaw(board, move);
                return res;
            }
        } else return false;
    }

    /// King movement rule check.
    fn kingMove(self: *Self, board: *Board, move: Move) bool {
        const binding = Move.moveToDxDy(@constCast(&move));
        const dx = binding[0];
        const dy = binding[1];
        const basic = @abs(dx) < 2 and @abs(dy) < 2;
        const dst_cell = &board.board[move.dst.y][move.dst.x];

        // castling movement check
        var dst_is_rook: bool = undefined;
        if(dst_cell.piece != null) {
            if(dst_cell.piece.?.who == .rook) dst_is_rook = true else dst_is_rook = false;
        } else dst_is_rook = false;

        // process castling
        if (dst_is_rook) {
            const king_cell = board.board[move.src.y][move.src.x];
            if (move.src.y != move.dst.y) return false;
            if (dst_cell.piece.?.moved or king_cell.piece.?.moved) return false;

            const start_x = @min(move.src.x, move.dst.x) + 1;
            const end_x = @max(move.src.x, move.dst.x) - 1;

            var x = start_x;
            while (x <= end_x) : (x += 1) {
                if (board.board[move.src.y][x].piece != null) {
                    return false;
                }
            }

            const king_new_x = if (dx > 0) move.src.x + 2 else move.src.x - 2;
            const rook_new_x = if (dx > 0) move.src.x + 1 else move.src.x - 1;

            // King moving
            board.board[move.src.y][king_new_x].piece = board.board[move.src.y][move.src.x].piece;
            board.board[move.src.y][move.src.x].piece = null;

            // Rook moving
            board.board[move.src.y][rook_new_x].piece = board.board[move.src.y][move.dst.x].piece;
            board.board[move.src.y][move.dst.x].piece = null;

            return true;
        }
        // process regular movement
        else {
            if (!(basic and self.legalCells(board, move))) return false;


            if(dst_cell.abb and self.color == .white) return false
            else if(dst_cell.abw and self.color == .black) return false
            else {
                Piece.movePieceRaw(board, move);
                return true;
            }
        }
    }

    /// Rook movement rule check.
    fn rookMove(self: *Self, board: *Board, move: Move) bool {
        const basic = (move.src.x == move.dst.x) != (move.src.y == move.dst.y);


        if (!(basic and self.legalCells(board, move))) return false;


        const dx: i8 = @as(i8, @intCast(move.dst.x)) - @as(i8, @intCast(move.src.x));
        const dy: i8 = @as(i8, @intCast(move.dst.y)) - @as(i8, @intCast(move.src.y));

        // Determine direction and distance for movement
        const x_direction: i8 = if (dx > 0) 1 else if (dx < 0) -1 else 0;
        const y_direction: i8 = if (dy > 0) 1 else if (dy < 0) -1 else 0;
        const distance = if (dx != 0) @abs(dx) else @abs(dy);

        // Check path for obstruction
        for (1..distance) |i| {
            if (distance == 1) { Piece.movePieceRaw(board, move); return true; } // If moving just one square, path is clear by definition
            const y: i9 = @as(i9, move.src.y) + (@as(i9, @intCast(i)) * y_direction);
            const x: i9 = @as(i9, move.src.x) + (@as(i9, @intCast(i)) * x_direction);
            const piece = &board.board[@intCast(y)][@intCast(x)].piece;
            if (piece.* != null) return false;
        }

        Piece.movePieceRaw(board, move);
        return true;
    }




    /// Check legality of source and destination cells.
    fn legalCells(self: *Self, board: *Board, move: Move) bool {
        const from_square = &board.board[move.src.y][move.src.x];
        const to_square = &board.board[move.dst.y][move.dst.x];

        // check from square has a piece
        if(from_square.piece == null) return false;
        // check from square is ours
        if (from_square.piece) |piece| {
            if (piece.color != self.color) return false;
        }
        // check to square is enemy or free
        if (to_square.piece) |piece| {
            if (piece.color == self.color) return false;
        }
        return true;
    }

    fn movePieceRaw(board: *Board, move: Move) void {
        const src_cell = &board.board[move.src.y][move.src.x];
        const dst_cell = &board.board[move.dst.y][move.dst.x];
        dst_cell.*.piece = src_cell.piece;
        src_cell.*.piece = null;
    }
};
