const raylib = @import("raylib");
const std = @import("std");

const Game = @import("Game.zig");
const Resources = @import("Resources.zig");
const Config = @import("ConfigFile.zig");
const Input = @import("Input.zig");

pub fn main() !void {
    var resources = Resources.init();
    var config = try Config.init();
    var game = try Game.init(&resources);
    const input = Input.init(&config.action_map);

    defer {
        game.deinit();
        config.deinit();
    }

    raylib.SetConfigFlags(raylib.ConfigFlags{
        .FLAG_WINDOW_RESIZABLE = true,
        .FLAG_FULLSCREEN_MODE = config.video.fullscreen,
    });

    raylib.InitWindow(config.video.resolution[0], config.video.resolution[1], "zell-life");
    raylib.SetTargetFPS(config.video.target_fps);

    defer raylib.CloseWindow();

    while (!raylib.WindowShouldClose()) {
        if (raylib.IsWindowResized() and !raylib.IsWindowFullscreen()) {
            config.video.resolution[0] = @intCast(raylib.GetScreenWidth());
            config.video.resolution[1] = @intCast(raylib.GetScreenHeight());
        }

        try game.update(input, raylib.GetFrameTime());
        try game.render(raylib.GetFrameTime());
    }
}
