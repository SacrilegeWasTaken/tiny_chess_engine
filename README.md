# Zig chess game engine.
This repository provides you simple and fast API for chess engine.
API includes `Engine` struct and some member functions.
```zig
// allocate the Engine on the heap
pub fn init(allocator: std.mem.Allocator) !*Self;
// free the memory
pub fn deinit(self: *Self, allocator: std.mem.Allocator) void;
// sets the timer for the game
pub fn setTimer(self: *Self, secs: u64) !void;
// starts the game
pub fn startGame(self: *Self) !void;
// input move (no need in CLI mode)
pub fn inputMove(self: *Self, mov: []const u8) !void;
```

# Main features are:
- Simplicity
- Small binary
- Fast perfomance
- Togglable CLI inteface for the game
- Memory safety
- Panic safety

# Current progress
***[############-----------------------------]***
