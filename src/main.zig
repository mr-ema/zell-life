const raylib = @import("raylib");
const std = @import("std");
const rand = std.rand;

const SCREEN_WIDTH = 500;
const SCREEN_HEIGHT = 500;
const CELL_SIZE = 3;
const TARGET_FPS = 20;

const CellState = enum { Dead, Alive };
const Vector2 = struct { x: usize, y: usize };

fn randomInRange(comptime T: type, min: T, max: T) T {
    const seed = @truncate(u64, @bitCast(u128, std.time.nanoTimestamp()));
    var prng = rand.DefaultPrng.init(seed);

    const result = prng.random().intRangeAtMost(T, min, max);
    return result;
}

fn Grid(comptime height: usize, comptime width: usize) type {
    return struct {
        const Self = @This();

        height: usize,
        width: usize,
        grid: [height][width]CellState,

        pub fn init() Self {
            var grid: [height][width]CellState = undefined;

            for (grid, 0..) |row, i| {
                for (row, 0..) |_, j| {
                    const randonState = randomInRange(u8, 0, 1);
                    grid[i][j] = if (randonState == 1) CellState.Alive else CellState.Dead;
                }
            }

            return Self{ .height = height, .width = width, .grid = grid };
        }

        fn countAliveNeighbors(self: *Self, c: Vector2) u8 {
            var count: u8 = 0;
            const neighbors = [_]usize{ 0, 1, 2 };

            // temporal fix
            var cx = if (c.x <= 1) 1 else c.x - 1;
            var cy = if (c.y <= 1) 1 else c.y - 1;

            for (neighbors) |dx| {
                for (neighbors) |dy| {
                    if (self.grid[cx + dx - 1][cy + dy - 1] == CellState.Alive) {
                        count += 1;
                    }
                }
            }

            return count;
        }

        pub fn update(self: *Self) void {
            // Rules:
            // 1. Any live cell with fewer than two live neighbors dies, as if by underpopulation.
            // 2. Any live cell with two or three live neighbors survives to the next generation.
            // 3. Any live cell with more than three live neighbors dies, as if by overpopulation.
            // 4. Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.

            var new_grid: [height][width]CellState = undefined;

            for (self.grid, 0..) |row, i| {
                for (row, 0..) |cell, j| {
                    var neighbors = countAliveNeighbors(self, Vector2{ .x = i, .y = j });

                    if (cell == CellState.Dead) {
                        new_grid[i][j] = if (neighbors == 3) CellState.Alive else CellState.Dead;
                    } else {
                        new_grid[i][j] = if (neighbors < 2 or neighbors > 3) CellState.Dead else CellState.Alive;
                    }
                }
            }

            self.grid = new_grid;
        }
    };
}

pub fn main() void {
    raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "zell-life");
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.SetTargetFPS(TARGET_FPS);

    defer raylib.CloseWindow();

    var grid = Grid(SCREEN_HEIGHT, SCREEN_WIDTH).init();

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);
        raylib.DrawFPS(10, 10);

        for (grid.grid, 0..) |row, y| {
            for (row, 0..) |state, x| {
                if (state == CellState.Alive) {
                    raylib.DrawRectangle(@intCast(i32, x * CELL_SIZE / 2), @intCast(i32, y * CELL_SIZE / 2), CELL_SIZE, CELL_SIZE, raylib.BLACK);
                }
            }
        }

        grid.update();
    }
}
