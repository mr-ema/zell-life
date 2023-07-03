const raylib = @import("raylib");
const std = @import("std");
const Cell = @import("cell.zig");
const Grid = Cell.Grid;
const CellState = Cell.CellState;

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 600;
const CELL_SIZE = 4;
const TARGET_FPS = 20;

pub fn main() void {
    raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "zell-life");
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.SetTargetFPS(TARGET_FPS);

    defer raylib.CloseWindow();

    var camera: raylib.Camera2D = undefined;
    camera.zoom = 1.0;

    var grid = Grid(SCREEN_HEIGHT / (CELL_SIZE / 2), SCREEN_WIDTH / (CELL_SIZE / 2)).init();

    while (!raylib.WindowShouldClose()) {
        // Translate based on mouse right click
        if (raylib.IsMouseButtonDown(.MOUSE_BUTTON_RIGHT)) {
            var delta = raylib.GetMouseDelta();
            delta = raylib.Vector2Scale(delta, -1.0 / camera.zoom);

            camera.target = raylib.Vector2Add(camera.target, delta);
        }

        // Zoom based on mouse wheel
        var wheel: f32 = raylib.GetMouseWheelMove();
        if (wheel != 0) {
            var mouseWorldPos = raylib.GetScreenToWorld2D(raylib.GetMousePosition(), camera);

            camera.offset = raylib.GetMousePosition();

            camera.target = mouseWorldPos;

            const zoomIncrement: f32 = 0.125;
            camera.zoom += (wheel * zoomIncrement);
            if (camera.zoom < zoomIncrement) {
                camera.zoom = zoomIncrement;
            }
        }

        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);

        raylib.BeginMode2D(camera);
        for (grid.grid, 0..) |row, y| {
            for (row, 0..) |state, x| {
                if (state == .Alive) {
                    raylib.DrawRectangle(@intCast(i32, x * CELL_SIZE), @intCast(i32, y * CELL_SIZE), CELL_SIZE, CELL_SIZE, raylib.BLACK);
                }
            }
        }
        raylib.EndMode2D();

        grid.update();
    }
}
