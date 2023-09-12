const std = @import("std");
const raylib = @import("raylib");

const Self = @This();
const Game = @import("../Game.zig");

// TODO: add option to purge all the cells. (GameOfLife.cellPurgeProtocol())
// TODO: add option to resume game of life.

pub fn init() !Self {
    return Self{};
}

pub fn deinit(self: *Self) void {
    self.* = undefined;
}

pub fn update(self: *Self, total_time: f32, delta_time: f32) !void {
    _ = total_time;
    _ = delta_time;

    if (raylib.IsKeyPressed(.KEY_SPACE)) {
        Game.fromComponent(self).switchToState(.gameplay);
    }
}

pub fn render(self: *Self, total_time: f32, delta_time: f32) !void {
    _ = self;
    _ = total_time;
    _ = delta_time;

    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    raylib.ClearBackground(raylib.RAYWHITE);
}
