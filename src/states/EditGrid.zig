const std = @import("std");
const raylib = @import("raylib");

const Self = @This();
const Game = @import("../Game.zig");
const Resources = @import("../Resources.zig");
const Input = @import("../Input.zig");
const GameOfLife = @import("../GameOfLife.zig");
const Commands = @import("../Commands.zig");

resources: *Resources,

cam: *raylib.Camera2D,

pub fn init(resources: *Resources) !Self {
    return Self{ .resources = resources, .cam = &resources.cam };
}

pub fn deinit(self: *Self) void {
    self.* = undefined;
}

pub fn update(self: *Self, input: Input, total_time: f32, delta_time: f32) !void {
    _ = total_time;
    _ = delta_time;

    if (input.isActionJustPressed(.toggle_edit)) {
        Game.fromComponent(self).switchToState(.gameplay);
    }

    if (raylib.IsMouseButtonDown(.MOUSE_BUTTON_LEFT)) {
        const mouse_screen_pos = raylib.GetMousePosition();
        var mouse_world_pos = raylib.GetScreenToWorld2D(mouse_screen_pos, self.cam.*);

        if (mouse_world_pos.x >= 0.0 and mouse_world_pos.y >= 0.0) {
            var cell_x: u32 = @intFromFloat(mouse_world_pos.x);
            var cell_y: u32 = @intFromFloat(mouse_world_pos.y);

            self.resources.gol.toggleCellState(cell_x, cell_y) catch |err| {
                if (err == error.OutOfBounds) {
                    std.debug.print("[INFO] (EditGrid): resources.gol index out of bounds (x: {d}, y: {d})\n", .{ cell_x, cell_y });
                }
                return;
            };
        }
    }

    if (input.isActionPressed(.translate_cam)) {
        Commands.translateCam(self.cam);
    }

    var wheel: f32 = raylib.GetMouseWheelMove();
    if (input.isActionPressed(.zoom_in) or wheel > 0) {
        Commands.zoomIn(self.cam);
    } else if (input.isActionPressed(.zoom_out) or wheel < 0) {
        Commands.zoomOut(self.cam);
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
