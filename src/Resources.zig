const raylib = @import("raylib");

const Self = @This();
const GameOfLife = @import("GameOfLife.zig");

gol: GameOfLife = undefined,
cam: raylib.Camera2D = .{ .zoom = 1.0, .target = undefined },
zoom_increment: f32 = 0.125,

pub fn init() Self {
    return Self{ .gol = GameOfLife.init() };
}

pub fn zoomIn(self: *Self) void {
    const delta = 2.0;
    var mouse_world_pos = raylib.GetScreenToWorld2D(raylib.GetMousePosition(), self.cam);

    self.cam.offset = raylib.GetMousePosition();

    self.cam.target = mouse_world_pos;

    self.cam.zoom += (delta * self.zoom_increment);

    if (self.cam.zoom < self.zoom_increment) {
        self.cam.zoom = self.zoom_increment;
    }
}

pub fn zoomOut(self: *Self) void {
    const delta = -2.0;
    var mouse_world_pos = raylib.GetScreenToWorld2D(raylib.GetMousePosition(), self.cam);

    self.cam.offset = raylib.GetMousePosition();

    self.cam.target = mouse_world_pos;

    self.cam.zoom += (delta * self.zoom_increment);

    if (self.cam.zoom < self.zoom_increment) {
        self.cam.zoom = self.zoom_increment;
    }
}
