const std = @import("std");
const raylib = @import("raylib");

const Self = @This();
const Allocator = std.mem.Allocator;
const GameOfLife = @import("GameOfLife.zig");

gol: GameOfLife = undefined,
cam: raylib.Camera2D = .{ .zoom = 1.0, .target = undefined },

pub fn init(allocator: *Allocator) !Self {
    var self = Self{};
    self.gol = try GameOfLife.init(allocator);

    return self;
}

pub fn deinit(self: *Self, allocator: *Allocator) void {
    _ = allocator;
    self.gol.deinit();
}
