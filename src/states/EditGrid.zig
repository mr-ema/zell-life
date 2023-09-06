const std = @import("std");
const raylib = @import("raylib");

const Self = @This();
const Game = @import("../Game.zig");
const Resources = @import("../Resources.zig");
const GameOfLife = @import("../GameOfLife.zig");

resources: *Resources,

cam: *raylib.Camera2D,
zoom_increment: f32 = 0.125,

pub fn init(resources: *Resources) !Self {
    return Self{ .resources = resources, .cam = &resources.cam };
}

pub fn deinit(self: *Self) void {
    self.* = undefined;
}

pub fn update(self: *Self, total_time: f32, delta_time: f32) !void {
    _ = total_time;
    _ = delta_time;

    if (raylib.IsKeyPressed(.KEY_E)) {
        Game.fromComponent(self).switchToState(.gameplay);
    }

    if (raylib.IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) {
        const mouse_screen_pos = raylib.GetMousePosition();
        var mouse_world_pos = raylib.GetScreenToWorld2D(mouse_screen_pos, self.cam.*);

        if (mouse_world_pos.x >= 0.0 and mouse_world_pos.y >= 0.0) {
            var cell_x: u32 = @intFromFloat(mouse_world_pos.x);
            var cell_y: u32 = @intFromFloat(mouse_world_pos.y);

            self.resources.gol.toggleCellState(cell_x, cell_y) catch |err| {
                if (err == error.OutOfBounds) {
                    std.debug.print("EditGrid: resources.gol index out of bounds (x: {d}, y: {d})\n", .{ cell_x, cell_y });
                }
                return;
            };
        }
    }

    // Translate based on mouse right click
    if (raylib.IsMouseButtonDown(.MOUSE_BUTTON_RIGHT)) {
        var delta = raylib.GetMouseDelta();
        delta = raylib.Vector2Scale(delta, -1.0 / self.cam.zoom);

        self.cam.target = raylib.Vector2Add(self.cam.target, delta);
    }

    // Zoom based on mouse wheel
    var wheel: f32 = raylib.GetMouseWheelMove();
    if (wheel != 0) {
        var mouse_world_pos = raylib.GetScreenToWorld2D(raylib.GetMousePosition(), self.cam.*);

        self.cam.offset = raylib.GetMousePosition();

        self.cam.target = mouse_world_pos;

        self.cam.zoom += (wheel * self.zoom_increment);
        if (self.cam.zoom < self.zoom_increment) {
            self.cam.zoom = self.zoom_increment;
        }
    }
}

pub fn render(self: *Self, total_time: f32, delta_time: f32) !void {
    _ = total_time;
    _ = delta_time;

    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    raylib.ClearBackground(raylib.RAYWHITE);

    {
        raylib.BeginMode2D(self.cam.*);
        defer raylib.EndMode2D();

        for (self.resources.gol.grid, 0..) |row, y| {
            for (row, 0..) |state, x| {
                if (state == .Alive) {
                    raylib.DrawPixel(@intCast(x), @intCast(y), raylib.BLACK);
                }
            }
        }
    }
}
