const pieces = @import("pieces.zig");
const Piece = pieces.Piece;
const PType = pieces.PType;
const Color = pieces.Color;

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
        return Self { .piece = Piece{
            .ptype = T,
            .pside = C,
        } };
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
        for (&self.board, 0..8) |*row, y| {
            switch (y) {
                0 => { // while cool pieces
                    const side = Color.white;
                    row.* = .{
                        Cell.piece(.rook, side),    Cell.piece(.knight, side),
                        Cell.piece(.bishop, side),  Cell.piece(.queen, side),
                        Cell.piece(.king, side),    Cell.piece(.bishop, side),
                        Cell.piece(.knight, side),  Cell.piece(.rool, side),
                    };
                },
                1 => { // white pawns
                    const side = .white;
                    for (row) |*square| {
                        square.* = Cell.piece(.pawn, side);
                    }
                },
                6 => { // black pawns
                    const side = .black;
                    for (row) |*square| {
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
                    for (row) |*square| {
                        square.piece = null;
                    }
                },
            }
        }
    }
    /// Moves pieces without checking they can or no.
    fn movePiece(self: *Self, move: Move) bool {
        const src_cell = &self.board[move.src.y][move.src.x];
        if(src_cell.piece == null) return false;
        return src_cell.piece.?.moveChecked(&self.board, move);
    }
    /// Updating Cells attack field. Call it after every
    /// move, so king can know he's checked or checkmated
    fn updateAttackFields(self: *Self) void {
        _ = self;
    }
};
