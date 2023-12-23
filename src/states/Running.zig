const std = @import("std");
const raylib = @import("raylib");
const raygui = @import("raygui");

const FixedBufferAllocator = std.heap.FixedBufferAllocator;

const Self = @This();
const Game = @import("../Game.zig");
const Resources = @import("../Resources.zig");
const Input = @import("../Input.zig");
const GameOfLife = @import("../GameOfLife.zig");
const Commands = @import("../Commands.zig");

var buf: [256]u8 = undefined;
var fba: FixedBufferAllocator = FixedBufferAllocator.init(&buf);

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
    if (input.isActionJustPressed(.toggle_pause)) {
        Game.fromComponent(self).switchToState(.freeze_time);
    } else if (input.isActionJustPressed(.toggle_edit)) {
        Game.fromComponent(self).switchToState(.edit_grid);
    } else if (input.isActionJustPressed(.purge_life)) {
        self.resources.gol.cellPurgeProtocol();
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

    self.resources.gol.update(delta_time);
}

pub fn render(self: *Self, total_time: f32, delta_time: f32) !void {
    _ = total_time;
    _ = delta_time;

    raylib.BeginDrawing();
    defer {
        raylib.EndDrawing();
        fba.reset();
    }

    raylib.ClearBackground(raylib.RAYWHITE);

    {
        raylib.BeginMode2D(self.cam.*);
        defer raylib.EndMode2D();

        for (self.resources.gol.grid, 0..) |row, y| {
            for (row, 0..) |state, x| {
                if (state == 1) {
                    raylib.DrawPixel(@intCast(x), @intCast(y), raylib.BLACK);
                }
            }
        }
    }

    // Render GUI elements without the camera's transformation
    drawUserInterface(self);

    raylib.DrawText(try raylib.TextFormat(fba.allocator(), "Gen: {d}", .{self.resources.gol.gen}), 10, 10, 20, raylib.DARKBLUE);
}

fn drawUserInterface(self: *Self) void {
    // Draw a box container for elements
    const start_x = raylib.GetScreenWidth() - 300;
    raylib.DrawLine(start_x, 0, start_x, raylib.GetScreenHeight(), raylib.Fade(raylib.LIGHTGRAY, 0.6));
    raylib.DrawRectangle(start_x, 0, start_x + 300, raylib.GetScreenHeight(), raylib.Fade(raylib.LIGHTGRAY, 0.8));

    // Speed element
    var slider_box: raylib.Rectangle = .{ .x = 0.0, .y = 20.0, .width = 120, .height = 30 };
    slider_box.x = @as(f32, @floatFromInt(raylib.GetScreenWidth())) - slider_box.width - 50;

    _ = raygui.GuiSliderBar(slider_box, "Speed", "", &self.resources.gol.update_speed, 1.0, 60.0);
}
