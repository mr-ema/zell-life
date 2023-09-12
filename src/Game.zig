const std = @import("std");

const Self = @This();
const Resources = @import("Resources.zig");
const Input = @import("Input.zig");

const initial_state = State.gameplay;

const States = struct {
    pub const Gameplay = @import("states/Running.zig");
    pub const PauseMenu = @import("states/PauseMenu.zig");
    pub const FreezeTime = @import("states/FreezeTime.zig");
    pub const EditGrid = @import("states/EditGrid.zig");
};

const State = enum { gameplay, pause_menu, freeze_time, edit_grid };

const Transition = struct {
    from: State,
    to: State,
};

const StateTransition = union(enum) {
    state: State,
    transition: Transition,
};

resources: *Resources,

current_state: StateTransition = .{ .state = initial_state },
next_state: ?State = null,

gameplay: States.Gameplay,
pause_menu: States.PauseMenu,
freeze_time: States.FreezeTime,
edit_grid: States.EditGrid,

update_time: f32 = 0.0,
render_time: f32 = 0.0,

pub fn init(resources: *Resources) !Self {
    var simulation = Self{
        .resources = resources,
        .gameplay = undefined,
        .pause_menu = try States.PauseMenu.init(),
        .freeze_time = try States.FreezeTime.init(resources),
        .edit_grid = try States.EditGrid.init(resources),
    };

    simulation.gameplay = try States.Gameplay.init(resources);
    errdefer simulation.gameplay.deinit();

    try simulation.callOnState(simulation.current_state.state, "enter", .{0.0});

    return simulation;
}

pub fn deinit(self: *Self) void {
    switch (self.current_state) {
        .state => |state| self.callOnState(state, "leave", .{self.update_time}) catch unreachable,

        // if we are currently in a transition, leave the state we transition to
        .transition => |t| self.callOnState(t.to, "leave", .{self.update_time}) catch unreachable,
    }

    self.gameplay.deinit();
    self.* = undefined;
}

fn callOnState(self: *Self, state: State, comptime fun: []const u8, args: anytype) !void {
    const H = struct {
        fn maybeCall(ptr: anytype, inner_args: anytype) !void {
            const F = @TypeOf(ptr.*);
            if (@hasDecl(F, fun)) {
                const args_tuple = .{ptr} ++ inner_args;
                return @call(.auto, @field(F, fun), args_tuple);
            }
        }
    };
    switch (state) {
        .gameplay => return H.maybeCall(&self.gameplay, args),
        .pause_menu => return H.maybeCall(&self.pause_menu, args),
        .freeze_time => return H.maybeCall(&self.freeze_time, args),
        .edit_grid => return H.maybeCall(&self.edit_grid, args),
    }
}

pub fn update(self: *Self, input: Input, delta_time: f32) !void {
    defer self.update_time += delta_time;

    if (self.next_state != null) {
        std.debug.assert(self.current_state == .state);
        std.debug.assert(self.current_state.state != self.next_state.?);

        // workaround for result location problem
        const current_state = self.current_state.state;

        try self.callOnState(current_state, "leave", .{self.update_time});
        try self.callOnState(self.next_state.?, "enter", .{self.update_time});

        self.current_state = .{
            .transition = .{
                .from = current_state,
                .to = self.next_state.?,
            },
        };
        self.next_state = null;
    }

    switch (self.current_state) {
        .state => |state| try self.callOnState(state, "update", .{ input, self.update_time, delta_time }),
        .transition => {}, // do not update game logic in transitions
    }
}

fn renderState(self: *Self, state: State, delta_time: f32) !void {
    switch (state) {
        .gameplay => try self.gameplay.render(self.render_time, delta_time),
        .pause_menu => try self.pause_menu.render(self.render_time, delta_time),
        .freeze_time => try self.freeze_time.render(self.render_time, delta_time),
        .edit_grid => try self.edit_grid.render(self.render_time, delta_time),
    }
}

pub fn render(self: *Self, delta_time: f32) !void {
    defer self.render_time += delta_time;

    switch (self.current_state) {
        .state => |state| try self.callOnState(state, "render", .{
            self.render_time,
            delta_time,
        }),
        .transition => |*transition| {
            try self.callOnState(transition.from, "render", .{
                self.render_time,
                delta_time,
            });
            try self.callOnState(transition.to, "render", .{
                self.render_time,
                delta_time,
            });

            self.current_state = .{
                .state = transition.to,
            };
        },
    }
}

pub fn switchToState(self: *Self, new_state: State) void {
    std.debug.assert(self.current_state == .state);
    std.debug.assert(self.current_state.state != new_state);
    std.debug.assert(self.next_state == null);
    self.next_state = new_state;
}

pub fn fromComponent(component: anytype) *Self {
    comptime var field_name: ?[]const u8 = null;
    inline for (std.meta.fields(Self)) |fld| {
        if (fld.type == @TypeOf(component.*)) {
            if (field_name != null)
                @compileError("There are two components of that type declared in Game. Please use @fieldParentPtr directly!");

            field_name = fld.name;
        }
    }
    if (field_name == null)
        @compileError("The game has no matching component of that type.");

    return @fieldParentPtr(Self, field_name.?, component);
}
