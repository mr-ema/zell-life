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

    if (input.isKeyPressed(.toggle_stop)) {
        Game.fromComponent(self).switchToState(.freeze_time);
    } else if (input.isKeyPressed(.toggle_edit)) {
        Game.fromComponent(self).switchToState(.edit_grid);
    } else if (input.isKeyPressed(.purge_life)) {
        self.resources.gol.cellPurgeProtocol();
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

        const zoom_increment: f32 = 0.125;
        self.cam.zoom += (wheel * zoom_increment);
        if (self.cam.zoom < zoom_increment) {
            self.cam.zoom = zoom_increment;
        }
    }

    self.resources.gol.update();
}

pub fn render(self: *Self, total_time: f32, delta_time: f32) !void {
    _ = total_time;
    _ = delta_time;

    raylib.BeginDrawing();
    defer {
        raylib.EndDrawing();
        self.fba.reset();
    }

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
}
