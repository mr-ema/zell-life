const rl = @import("raylib");
const Cam = rl.Camera2D;

const Self = @This();

pub fn zoomIn(cam: *Cam) void {
    const delta = 0.125;
    const zoom_increment = 2.0;

    var mouse_world_pos = rl.GetScreenToWorld2D(rl.GetMousePosition(), cam.*);
    cam.offset = rl.GetMousePosition();
    cam.target = mouse_world_pos;

    cam.zoom += (delta * zoom_increment);
    if (cam.zoom < delta) {
        cam.zoom = delta;
    }
}

pub fn zoomOut(cam: *Cam) void {
    const delta = 0.125;
    const zoom_increment = -2.0;

    var mouse_world_pos = rl.GetScreenToWorld2D(rl.GetMousePosition(), cam.*);
    cam.offset = rl.GetMousePosition();
    cam.target = mouse_world_pos;

    cam.zoom += (delta * zoom_increment);
    if (cam.zoom < delta) {
        cam.zoom = delta;
    }
}

pub fn translateCam(cam: *Cam) void {
    var delta = rl.GetMouseDelta();
    delta = rl.Vector2Scale(delta, -1.0 / cam.zoom);

    cam.target = rl.Vector2Add(cam.target, delta);
}
