const rl = @import("raylib");
const con = @import("config.zig");
const uti = @import("utils.zig");
const obj = @import("objects.zig");
const val = @import("values.zig");
const std = @import("std");

pub fn handle_controls(state: con.GameState) void {
    // Left joystick - Movement
    const leftx = rl.getGamepadAxisMovement(0, rl.GamepadAxis.left_x);
    const lefty = rl.getGamepadAxisMovement(0, rl.GamepadAxis.left_y);
    if (@abs(leftx) > 0.15 or @abs(lefty) > 0.15) {
        const player_angle = uti.angle_from_gamepad(leftx, lefty);
        const player_speed = state.player.speed * @min(1.0, @abs(leftx) + @abs(lefty));
        const player_move = uti.get_angle_movement(player_speed, player_angle);
        state.player.drawable.rect_dest.x += player_move.x;
        state.player.drawable.rect_dest.y += player_move.y;
    }

    // Right joystick - Facing
    const rightx = rl.getGamepadAxisMovement(0, rl.GamepadAxis.right_x);
    const righty = rl.getGamepadAxisMovement(0, rl.GamepadAxis.right_y);
    if (@abs(rightx) > 0.15 or @abs(righty) > 0.15) {
        const turn_target = uti.angle_from_gamepad(rightx, righty) + 90;
        state.player.drawable.facing = turn_target;
    }

    if (rl.isGamepadButtonPressed(0, rl.GamepadButton.right_face_right)) {
        const skill = &state.player.skills[0];
        skill.toggled = !skill.toggled;
    }

    if (rl.isGamepadButtonPressed(0, rl.GamepadButton.right_trigger_1)) {
        const skill = &state.player.skills[1];
        skill.use(skill, state);
    }

    if (rl.isGamepadButtonPressed(0, rl.GamepadButton.right_trigger_2)) {
        const skill = &state.player.skills[2];
        skill.use(skill, state);
    }

    if (rl.isGamepadButtonPressed(0, rl.GamepadButton.right_face_left)) {
        const skill = &state.player.skills[3];
        skill.use(skill, state);
    }
}
