const std = @import("std");
const rand = std.rand;
const Vector2 = struct { x: usize, y: usize };

pub const CellState = enum { Dead, Alive };

fn randomInRange(comptime T: type, min: T, max: T) T {
    const time: u128 = @bitCast(std.time.nanoTimestamp());
    const seed: u64 = @truncate(time);
    var prng = rand.DefaultPrng.init(seed);

    const result = prng.random().intRangeAtMost(T, min, max);
    return result;
}

pub fn Grid(comptime height: usize, comptime width: usize) type {
    return struct {
        const Self = @This();

        height: usize,
        width: usize,
        gen: u64,
        grid: [height][width]CellState,

        pub fn init() Self {
            var grid: [height][width]CellState = undefined;

            for (grid, 0..) |row, i| {
                for (row, 0..) |_, j| {
                    const randonState = randomInRange(u8, 0, 9);
                    grid[i][j] = if (randonState == 1) .Alive else .Dead;
                }
            }

            return Self{ .height = height, .width = width, .grid = grid, .gen = 1 };
        }

        fn countAliveNeighbors(self: *Self, c: Vector2) u8 {
            var count: u8 = 0;
            const dx = [_]i8{ -1, 0, 1, -1, 1, -1, 0, 1 };
            const dy = [_]i8{ -1, -1, -1, 0, 0, 1, 1, 1 };

            for (dx, 0..) |_, i| {
                const nx: isize = @intCast(@as(isize, @intCast(c.x)) + dx[i]);
                const ny: isize = @intCast(@as(isize, @intCast(c.y)) + dy[i]);

                if (nx >= 0 and nx < self.width and ny >= 0 and ny < self.height) {
                    const state = self.grid[@intCast(ny)][@intCast(nx)];

                    if (state == .Alive) {
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

            for (self.grid, 0..) |row, y| {
                for (row, 0..) |cell, x| {
                    var neighbors = countAliveNeighbors(self, Vector2{ .x = x, .y = y });

                    if (cell == .Dead) {
                        new_grid[y][x] = if (neighbors == 3) .Alive else .Dead;
                    } else {
                        new_grid[y][x] = if (neighbors < 2 or neighbors > 3) .Dead else .Alive;
                    }
                }
            }

            self.grid = new_grid;
            self.gen +%= 1;
        }
    };
}
