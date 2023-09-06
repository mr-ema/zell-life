const raylib = @import("raylib");
const std = @import("std");

const Game = @import("Game.zig");
const Resources = @import("Resources.zig");

const SCREEN_WIDTH = 1280;
const SCREEN_HEIGHT = 620;
const TARGET_FPS = 60;

pub fn main() !void {
    var resources = Resources.init();
    var game = try Game.init(&resources);
    defer game.deinit();

    raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "zell-life");
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.SetTargetFPS(TARGET_FPS);

    defer raylib.CloseWindow();

    while (!raylib.WindowShouldClose()) {
        try game.update(0);
        try game.render(0);
    }
}
