const raylib = @import("raylib");

const Self = @This();
const KeyMapping = @import("ConfigFile.zig").KeyMapping;

keymap: KeyMapping,

const KeyAction = enum(usize) {
    none = 0,
    toggle_menu,
    toggle_edit,
    purge_life,
    toggle_stop,
};

fn mapAction(self: Self, key_action: KeyAction) raylib.KeyboardKey {
    switch (key_action) {
        .none => return self.keymap.none,

        .toggle_menu => return self.keymap.toggle_menu,
        .toggle_edit => return self.keymap.toggle_edit,
        .purge_life => return self.keymap.purge_life,
        .toggle_stop => return self.keymap.toggle_stop,
    }
}

pub fn init(keymap: KeyMapping) Self {
    return Self{ .keymap = keymap };
}

pub fn isKeyPressed(self: Self, key_action: KeyAction) bool {
    const key = self.mapAction(key_action);
    const result: bool = raylib.IsKeyPressed(key);

    return result;
}

pub fn isAnyHit(self: Self) bool {
    _ = self;

    return false;
}
