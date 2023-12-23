const std = @import("std");
const utils = @import("utils.zig");
const debug = std.debug.print;
const mem = std.mem;

const Self = @This();
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const Vector2 = struct { x: usize, y: usize };

const CellState = u8;

var elapsed_time: f32 = 0.0;
var alloc: Allocator = undefined;

gen: u64 = 1,
update_speed: f32 = 1.0,
grid: [][]CellState = undefined,

pub fn init(allocator: *Allocator) !Self {
    var self = Self{};
    const default_size: Vector2 = .{ .x = 300, .y = 300 };
    alloc = allocator.*;

    self.grid = try alloc.alloc([]CellState, default_size.y);
    for (self.grid) |*row| {
        row.* = try alloc.alloc(CellState, default_size.x);
    }

    setGridRandomCellState(&self);

    return self;
}

pub fn deinit(self: *Self) void {
    for (self.grid) |row| {
        alloc.free(row);
    }
    alloc.free(self.grid);
}

fn setGridRandomCellState(self: *Self) void {
    for (self.grid[0..], 0..) |row, i| {
        for (row, 0..) |_, j| {
            var randonState = utils.randomInRange(u8, 0, 9);
            self.grid[i][j] = if (randonState == 1) 1 else 0;
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

        if (nx >= 0 and ny >= 0 and ny < self.grid.len and nx < self.grid[c.y].len) {
            count += self.grid[@intCast(ny)][@intCast(nx)] & 1;
        }
    }

    return count;
}

pub fn update(self: *Self, delta_time: f32) void {
    elapsed_time += delta_time;
    if (elapsed_time < 1.0 / self.update_speed) return;

    // Rules:
    // 1. Any live cell with fewer than two live neighbors dies, as if by underpopulation.
    // 2. Any live cell with two or three live neighbors survives to the next generation.
    // 3. Any live cell with more than three live neighbors dies, as if by overpopulation.
    // 4. Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.

    for (self.grid, 0..) |row, y| {
        for (row, 0..) |_, x| {
            var neighbors = countAliveNeighbors(self, Vector2{ .x = x, .y = y });
            const alive: bool = (self.grid[y][x] & 1) == 1;

            if (neighbors == 3 or (neighbors == 2 and alive)) {
                self.grid[y][x] |= 2;
            }
        }
    }

    for (self.grid, 0..) |row, y| {
        for (row, 0..) |_, x| {
            self.grid[y][x] >>= 1;
        }
    }

    self.gen +%= 1;

    elapsed_time = 0.0;
}

pub fn toggleCellState(self: *Self, row: usize, col: usize) error{OutOfBounds}!void {
    if (row >= self.grid.len or col >= self.grid[row].len) {
        return error.OutOfBounds;
    }

    self.grid[col][row] ^= 1;
}

pub fn cellPurgeProtocol(self: *Self) void {
    for (self.grid, 0..) |row, i| {
        for (row, 0..) |_, j| {
            self.grid[i][j] = 0;
        }
    }

    self.gen = 0;
}

fn isWorldFileLineValid(line: []u8) bool {
    for (line) |char| {
        if (!(char == '0' or char == '1')) {
            return false;
        }
    }

    return true;
}

// TODO: Optimize and add options to allow overwrite it...
pub fn saveWorldFile(self: *Self, file_path: []const u8) !void {
    const file = try std.fs.cwd().createFile(file_path, .{});
    defer file.close();

    const writer = file.writer();

    for (self.grid) |row| {
        for (row) |item| {
            _ = try writer.print("{d}", .{item});
        }
        _ = try writer.print("\n", .{});
    }
}

// TODO: Break function into smaller functions
pub fn loadWorldFile(self: *Self, file_path: []const u8) !void {
    const file = try std.fs.cwd().openFile(file_path, .{});
    var reader = file.reader();

    var content = std.ArrayList(u8).init(alloc);
    var content_ptr: usize = 0;
    var content_lines: usize = 0;
    defer {
        content.deinit();
        file.close();
    }

    while (true) {
        reader.streamUntilDelimiter(content.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        if (!isWorldFileLineValid(content.items[content_ptr..])) {
            return error.InvalidPatternFile;
        }

        _ = try content.writer().writeByte('\n');
        content_ptr = content.items.len;
        content_lines += 1;
    }

    var content_itr = mem.splitScalar(u8, content.items, '\n');

    // TODO: Implement a better solution
    _ = alloc.resize(self.grid, content_lines);
    self.grid.len = content_lines;
    for (self.grid, 0..) |row, i| {
        const line = content_itr.next();
        if (line == null) break;

        _ = alloc.resize(row, line.?.len);
        self.grid[i].len = line.?.len;
        for (self.grid[i], 0..) |_, j| {
            self.grid[i][j] = try std.fmt.charToDigit(line.?[j], 10);
        }
    }

    self.gen = 0;
}
