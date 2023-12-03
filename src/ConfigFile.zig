const std = @import("std");
const raylib = @import("raylib");
const Input = @import("Input.zig");

const Allocator = std.mem.Allocator;
const KeyboardKey = raylib.KeyboardKey;
const MouseButton = raylib.MouseButton;
const InputBinding = Input.InputBinding;

const Self = @This();

// TODO: use an external configuration file, using "YAML"|"TOML"|"JSON"

var buf: [1000]u8 = undefined;
var allocator: Allocator = std.heap.page_allocator;

video: Video = .{},
action_map: ActionMap = undefined,

pub const ActionMap = std.StringHashMap(InputBinding);

const Video = struct {
    resolution: [2]u16 = [_]u16{ 1280, 720 },
    fullscreen: bool = false,
    target_fps: u8 = 60,
};

pub fn init() !Self {
    var self = Self{ .action_map = ActionMap.init(allocator) };

    try self.action_map.put("none", .{ .key = .KEY_NULL });
    try self.action_map.put("toggle_menu", .{ .key = .KEY_P });
    try self.action_map.put("toggle_edit", .{ .key = .KEY_E });
    try self.action_map.put("toggle_pause", .{ .key = .KEY_SPACE });
    try self.action_map.put("purge_life", .{ .key = .KEY_K });
    try self.action_map.put("translate_cam", .{ .mouse_button = .MOUSE_BUTTON_RIGHT });
    try self.action_map.put("zoom_in", .{ .key = .KEY_EQUAL });
    try self.action_map.put("zoom_out", .{ .key = .KEY_MINUS });
    try self.action_map.put("toggle_cell_state", .{ .mouse_button = .MOUSE_BUTTON_LEFT });

    return self;
}

pub fn deinit(self: *Self) void {
    self.action_map.deinit();

    self.* = undefined;
}
