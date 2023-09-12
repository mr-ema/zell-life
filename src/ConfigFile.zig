const Video = struct {
    resolution: [2]u16 = [_]u16{ 1280, 720 },
    fullscreen: bool = false,
    target_fps: u8 = 60,
};

pub const video: Video = .{};
