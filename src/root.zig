const engine = @import("engine/engine.zig");

// TYPES
pub const Engine = engine.Engine;
pub const EngineError = engine.EngineError;

// FUNCTIONS
pub const init = Engine.init;
pub const deinit = Engine.deinit;
pub const setTimer = Engine.setTimer;
pub const inputMove = Engine.inputMove;
pub const startTimer = Engine.startTimer;
pub const switchTimer = Engine.switchTimer;
pub const checkTimeIsUp = Engine.checkTimeIsUp;
