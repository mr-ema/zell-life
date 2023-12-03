const raylib = @import("raylib");
const ActionMap = @import("ConfigFile.zig").ActionMap;

const Self = @This();
const KeyboardKey = raylib.KeyboardKey;
const MouseButton = raylib.MouseButton;

action_map: *ActionMap,

pub const Actions = enum(usize) {
    none = 0x00,

    toggle_menu,
    toggle_edit,
    purge_life,
    toggle_pause,
    translate_cam,
    zoom_in,
    zoom_out,
    toggle_cell_state,
};

pub const InputBinding = union(enum) {
    key: KeyboardKey,
    mouse_button: MouseButton,
};

pub fn init(action_map: *ActionMap) Self {
    return Self{ .action_map = action_map };
}

pub fn isActionPressed(self: Self, action: Actions) bool {
    const input = self.mapActionToInput(action);
    var should_fire: bool = false;

    switch (input) {
        .key => should_fire = raylib.IsKeyDown(input.key),
        .mouse_button => should_fire = raylib.IsMouseButtonDown(input.mouse_button),
    }

    return should_fire;
}

pub fn isActionJustPressed(self: Self, action: Actions) bool {
    const input = self.mapActionToInput(action);
    var should_fire: bool = false;

    switch (input) {
        .key => should_fire = raylib.IsKeyPressed(input.key),
        .mouse_button => should_fire = raylib.IsMouseButtonPressed(input.mouse_button),
    }

    return should_fire;
}

fn mapActionToInput(self: Self, action: Actions) InputBinding {
    switch (action) {
        .none => return self.action_map.get("none").?,

        .toggle_menu => return self.action_map.get("toggle_menu").?,
        .toggle_edit => return self.action_map.get("toggle_edit").?,
        .toggle_pause => return self.action_map.get("toggle_pause").?,
        .purge_life => return self.action_map.get("purge_life").?,
        .translate_cam => return self.action_map.get("translate_cam").?,
        .zoom_in => return self.action_map.get("zoom_in").?,
        .zoom_out => return self.action_map.get("zoom_out").?,
        .toggle_cell_state => return self.action_map.get("toggle_cell_state").?,
    }
}
