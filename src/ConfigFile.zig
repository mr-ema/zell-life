const raylib = @import("raylib");
const KeyboardKey = raylib.KeyboardKey;

pub const KeyMapping = struct {
    none: KeyboardKey = KeyboardKey.KEY_NULL,
    toggle_menu: KeyboardKey = KeyboardKey.KEY_P,
    toggle_edit: KeyboardKey = KeyboardKey.KEY_E,
    purge_life: KeyboardKey = KeyboardKey.KEY_K,
    toggle_stop: KeyboardKey = KeyboardKey.KEY_SPACE,
};

const Video = struct {
    resolution: [2]u16 = [_]u16{ 1280, 720 },
    fullscreen: bool = false,
    target_fps: u8 = 60,
};

pub const video: Video = .{};
pub const keymap: KeyMapping = .{};
