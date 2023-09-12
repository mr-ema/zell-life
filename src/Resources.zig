const raylib = @import("raylib");

const Self = @This();
const GameOfLife = @import("GameOfLife.zig");

// This is some kinda shared contex between states, I looking for better way
// to do it but for the moment this is the solution.

gol: GameOfLife = undefined,
cam: raylib.Camera2D = .{ .zoom = 1.0, .target = undefined },

pub fn init() Self {
    return Self{ .gol = GameOfLife.init() };
}
