const std = @import("std");
const raylib = @import("raylib");
const FixedBufferAllocator = std.heap.FixedBufferAllocator;

const Self = @This();
const Game = @import("../Game.zig");
const Resources = @import("../Resources.zig");
const Input = @import("../Input.zig");
const GameOfLife = @import("../GameOfLife.zig");

var buf: [256]u8 = undefined;

resources: *Resources,

cam: *raylib.Camera2D,
fba: FixedBufferAllocator = FixedBufferAllocator.init(&buf),

pub fn init(resources: *Resources) !Self {
    return Self{ .resources = resources, .cam = &resources.cam };
}

pub fn deinit(self: *Self) void {
    self.* = undefined;
}

pub fn update(self: *Self, input: Input, total_time: f32, delta_time: f32) !void {
    _ = total_time;
    _ = delta_time;

    if (input.isActionJustPressed(.toggle_pause)) {
        Game.fromComponent(self).switchToState(.gameplay);
    }

    if (input.isActionPressed(.translate_cam)) {
        var delta = raylib.GetMouseDelta();
        delta = raylib.Vector2Scale(delta, -1.0 / self.cam.zoom);

        self.cam.target = raylib.Vector2Add(self.cam.target, delta);
    }

    var wheel: f32 = raylib.GetMouseWheelMove();
    if (input.isActionPressed(.zoom_in) or wheel > 0) {
        self.resources.zoomIn();
    } else if (input.isActionPressed(.zoom_out) or wheel < 0) {
        self.resources.zoomOut();
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

    raylib.DrawText(try raylib.TextFormat(self.fba.allocator(), "Gen: {d}", .{self.resources.gol.gen}), 10, 10, 20, raylib.DARKBLUE);
    self.fba.reset();
}
