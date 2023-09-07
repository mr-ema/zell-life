const raylib = @import("raylib");
const std = @import("std");

const Game = @import("Game.zig");
const Resources = @import("Resources.zig");
const Config = @import("ConfigFile.zig");

pub fn main() !void {
    var resources = Resources.init();
    var game = try Game.init(&resources);
    defer game.deinit();

    raylib.InitWindow(Config.video.resolution[0], Config.video.resolution[1], "zell-life");
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.SetTargetFPS(Config.video.target_fps);

    defer raylib.CloseWindow();

    while (!raylib.WindowShouldClose()) {
        try game.update(0);
        try game.render(0);
    }
}
