const raylib = @import("raylib");

const Self = @This();
const GameOfLife = @import("GameOfLife.zig");

gol: GameOfLife = undefined,
cam: raylib.Camera2D = .{ .zoom = 1.0, .target = undefined },

pub fn init() Self {
    return Self{ .gol = GameOfLife.init() };
}
