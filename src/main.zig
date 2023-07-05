const raylib = @import("raylib");
const std = @import("std");
const Cell = @import("cell.zig");
const Grid = Cell.Grid;
const CellState = Cell.CellState;

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 600;
const CELL_SIZE = 2;
const TARGET_FPS = 60;

pub fn main() !void {
    var buf: [256]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var stop = false;

    raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "zell-life");
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.SetTargetFPS(TARGET_FPS);

    defer raylib.CloseWindow();

    var camera: raylib.Camera2D = undefined;
    camera.zoom = 1.0;

    var grid = Grid(SCREEN_HEIGHT / CELL_SIZE, SCREEN_WIDTH / CELL_SIZE).init();

    while (!raylib.WindowShouldClose()) {
        if (raylib.IsKeyPressed(.KEY_SPACE)) {
            stop = !stop;
        }

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

        {
            raylib.BeginDrawing();
            defer raylib.EndDrawing();

            raylib.ClearBackground(raylib.RAYWHITE);

            {
                raylib.BeginMode2D(camera);
                defer raylib.EndMode2D();

                for (grid.grid, 0..) |row, y| {
                    for (row, 0..) |state, x| {
                        if (state == .Alive) {
                            raylib.DrawRectangle(@intCast(i32, x * CELL_SIZE), @intCast(i32, y * CELL_SIZE), CELL_SIZE, CELL_SIZE, raylib.BLACK);
                        }
                    }
                }
            }

            raylib.DrawText(try raylib.TextFormat(fba.allocator(), "Gen: {d}", .{grid.gen}), 10, 10, 20, raylib.DARKBLUE);
            fba.reset();
        }

        if (!stop) {
            grid.update();
        }
    }
}
