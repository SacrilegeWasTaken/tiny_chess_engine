const pieces = @import("pieces.zig");
const Piece = pieces.Piece;
const PType = pieces.PType;
const Color = pieces.Color;
const EngineError = @import("engine.zig").EngineError;

/// # Fields
/// x -> column number
/// y -> row number
/// # Note!
/// `board[y][x]`! Such notation is way simplier
/// to code so you should just remember that.
pub const Pos = struct {
    x: u8,
    y: u8,
};
/// # Useful utility
/// Use it to simplify your code.
pub const Move = struct {
    src: Pos,
    dst: Pos,

    const Self = @This();

    pub inline fn moveToDxDy(move: *Self) struct { i8, i8 } {
        const xt: i8 = @intCast(move.dst.x);
        const xf: i8 = @intCast(move.src.x);
        const yt: i8 = @intCast(move.dst.y);
        const yf: i8 = @intCast(move.src.y);
        const dx = xt - xf;
        const dy = yt - yf;
        return .{dx, dy};
    }
};
/// # Fields
/// - piece -> optional Piece
/// - abb -> attacked by black
/// - abw -> attacked by white
/// # Note!
/// Board must set abb and abw correctly!
pub const Cell = struct {
    piece:  ?Piece,
    abb:    bool,
    abw:    bool,

    const Self = @This();

    pub fn piece(comptime T: PType, comptime C: Color) Self {
        return Self {
            .piece = Piece{
                .who    = T,
                .color  = C,
                .moved  = false,
            },
            .abb = false,
            .abw = false,
        };
    }
};
/// # Fields
/// - board -> representation of board matrix
/// # Note!
/// Board matrix indexing works wierd, but it's for algorithm's
/// simplicity. So you sould index elements like *`&board[y][x]`.*
/// Take *`Cell`'s* by pointer to memory economy and perfomance increase,
/// and index them *`[y][x]`* instead of *`[x][y]`*.
pub const Board = struct {
    board: [8][8]Cell,

    const Self = @This();
    /// Creating board. No heap allocation needed.
    /// Lives on stack, and calls *`board.reset()`* function
    /// before returning the Struct, so it's ready to play.
    pub fn create() Self {
        var board: Self = .{ .board = undefined };
        board.reset();
        return board;
    }
    /// Reseting the board to initial state.
    pub fn reset(self: *Self) void {
        inline for (&self.board, 0..8) |*row, y| {
            switch (y) {
                0 => { // while cool pieces
                    const side = Color.white;
                    row.* = .{
                        Cell.piece(.rook, side),    Cell.piece(.knight, side),
                        Cell.piece(.bishop, side),  Cell.piece(.queen, side),
                        Cell.piece(.king, side),    Cell.piece(.bishop, side),
                        Cell.piece(.knight, side),  Cell.piece(.rook, side),
                    };
                },
                1 => { // white pawns
                    const side = .white;
                    inline for (row) |*square| {
                        square.* = Cell.piece(.pawn, side);
                    }
                },
                6 => { // black pawns
                    const side = .black;
                    inline for (row) |*square| {
                        square.* = Cell.piece(.pawn, side);
                    }
                },
                7 => { // black cool pieces
                    const side = .black;
                    row.* = .{
                        Cell.piece(.rook, side),    Cell.piece(.knight, side),
                        Cell.piece(.bishop, side),  Cell.piece(.queen, side),
                        Cell.piece(.king, side),    Cell.piece(.bishop, side),
                        Cell.piece(.knight, side),  Cell.piece(.rook, side),
                    };
                },
                else => { // nulls
                    inline for (row) |*square| {
                        square.piece = null;
                    }
                },
            }
        }
    }
    /// Move piece
    pub fn movePiece(self: *Self, move: Move) !void {
        const src_cell = &self.board[move.src.y][move.src.x];
        if(src_cell.piece == null) return error.IllegalMove;
        if (!(src_cell.piece.?.moveChecked(@constCast(self), move))) return error.IllegalMove;
    }

    /// Updating Cells attack field. Call it after every
    /// move, so king can know he's checked or checkmated
    pub fn updateAttackFields(self: *Self) void {
        // iterate through all cells and set them to not attacked
        inline for(0..8) |y| {
            inline for(0..8) |x| {
                const cell = &self.board[x][y];
                cell.abb == false;
                cell.abw == false;
            }
        }
        // iterate through all cells and call piece markattacked method
        inline for(0..8) |y| {
            inline for(0..8) |x| {
                const cell = &self.board[x][y];
                if(cell.piece != null) {
                    cell.piece.?.markAttackedCells(&self.board, .{x, y});
                }
            }
        }
    }

    pub fn isKingChecked(self: *Self, king: *Piece, pos: Pos) bool {
        if(king.color == .white) return self.board[pos.y][pos.x].abb
        else return self.board[pos.y][pos.x].abw;
    }

    pub fn isCheckmate(self: *Self, king: *Piece, pos: Pos) bool {
        const king_moves = [_][2]i8{
            .{ 1, 0 }, .{ 1, 1 }, .{ 0, 1 }, .{ -1, 1 },
            .{ -1, 0 }, .{ -1, -1 }, .{ 0, -1 }, .{ 1, -1 },
        };

        const color = king.color;
        var checkmated = true;
        for (king_moves) |mov| {
            const newX = @as(i16, pos.x) + @as(i16, mov[0]);
            const newY = @as(i16, pos.y) + @as(i16, mov[1]);

            if (newX >= 0 and newX <= 7 and newY >= 0 and newY <= 7) {
                const cell = &self.board[@intCast(newY)][@intCast(newX)];
                if(cell.piece == null) {
                    if(color == .white) {
                        checkmated = checkmated and cell.abb;
                    } else checkmated = checkmated and cell.abw;
                }
            }
        }
    }

    fn findKing(self: *Self, color: Color) struct {*Piece, Pos} {
        const king: *Piece = undefined;
        const pos: Pos = undefined;

        inline for(0..8) |y| {
            inline for(0..8) |x| {
                const piece = &self.board[y][x].piece;
                if(piece != null and piece.*.?.who == .king and piece.*.?.color == color) {
                    king = &piece.*.?;
                    pos = .{.x = x, .y = y};
                }
            }
        }

        return .{ .king = king, .pos = pos };
    }

};
