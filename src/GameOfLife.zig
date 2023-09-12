const std = @import("std");
const utils = @import("utils.zig");

const Self = @This();
const Vector2 = struct { x: usize, y: usize };
const CellState = enum { Dead, Alive };

const rows = 500;
const cols = 500;

gen: u64 = 1,

grid: [rows][cols]CellState = undefined,

pub fn init() Self {
    var self = Self{};
    setGridRandomCellState(&self);

    return self;
}

fn setGridRandomCellState(self: *Self) void {
    for (self.grid, 0..) |row, i| {
        for (row, 0..) |_, j| {
            var randonState = utils.randomInRange(u8, 0, 9);
            self.grid[i][j] = if (randonState == 1) .Alive else .Dead;
        }
    }
}

fn countAliveNeighbors(self: *Self, c: Vector2) u8 {
    var count: u8 = 0;
    const dx = [_]i8{ -1, 0, 1, -1, 1, -1, 0, 1 };
    const dy = [_]i8{ -1, -1, -1, 0, 0, 1, 1, 1 };

    for (dx, 0..) |_, i| {
        const nx: isize = @intCast(@as(isize, @intCast(c.x)) + dx[i]);
        const ny: isize = @intCast(@as(isize, @intCast(c.y)) + dy[i]);

        if (nx >= 0 and nx < cols and ny >= 0 and ny < rows) {
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

    var new_grid: [rows][cols]CellState = undefined;

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

pub fn toggleCellState(self: *Self, row: usize, col: usize) error{OutOfBounds}!void {
    if (row >= rows or col >= cols) {
        return error.OutOfBounds;
    }

    const cell = self.grid[col][row];
    self.grid[col][row] = if (cell == .Dead) .Alive else .Dead;
}

pub fn cellPurgeProtocol(self: *Self) void {
    for (self.grid, 0..) |row, i| {
        for (row, 0..) |_, j| {
            self.grid[i][j] = .Dead;
        }
    }

    self.gen = 0;
}
