const rl = @import("raylib");
const obj = @import("objects.zig");
const con = @import("config.zig");
const std = @import("std");
const math = std.math;

pub fn reset_game_status(state: con.GameState) void {
    for (state.bullets, 0..) |_, i| {
        state.bullets[i] = .{ .drawable = undefined, .speed = undefined, .active = false };
    }
    for (state.enemies, 0..) |_, i| {
        state.enemies[i] = .{
            .drawable = undefined,
            .speed = undefined,
            .move_delay = undefined,
            .shoot_delay = undefined,
            .alive = false,
            .health = undefined,
        };
    }
    state.spawn_timer.* = 0;
    state.player.score = 0;
    state.player.health = 5; // MOVE TO CONFIG
}

pub fn draw_object(object: obj.Drawable) void {
    const x_shift = object.rect_dest.width / 2;
    const y_shift = object.rect_dest.height / 2;
    rl.drawTexturePro(
        object.texture,
        object.rect_source,
        .{
            .x = object.rect_dest.x + x_shift,
            .y = object.rect_dest.y + y_shift,
            .width = object.rect_dest.width,
            .height = object.rect_dest.height,
        },
        .{ .x = x_shift, .y = y_shift },
        object.facing,
        rl.Color.white,
    );
}

pub fn update_facing(object: *obj.Drawable, speed: f32, target: f32) void {
    var dif = object.facing - target;
    // std.debug.print("Facing: {d}, Target: {d}, Dif: {d}\n", .{ object.facing, target, dif });
    if (@abs(dif) <= speed) {
        object.facing = target;
        return;
    }
    if (dif < 0) {
        dif += 360;
    }

    if (dif < 180) {
        object.facing -= speed;
    } else {
        object.facing += speed;
    }
    if (object.facing < 0) {
        object.facing += 360;
    }
    if (object.facing >= 360) {
        object.facing -= 360;
    }
}

pub fn get_angle_movement(speed: f32, angle: f32) rl.Vector2 {
    const rad = math.degreesToRadians(angle);
    return .{
        .x = math.cos(rad) * speed,
        .y = math.sin(rad) * speed,
    };
}

pub fn get_random_border_position(width: f32, height: f32) rl.Vector2 {
    const side = rl.getRandomValue(0, 1); // 0 is X, 1 is Y
    const other = rl.getRandomValue(0, 1); // 0 is top/left, 1 is bot/right
    const width_int: i32 = @intFromFloat(width);
    const height_int: i32 = @intFromFloat(height);

    if (side == 0) {
        const x: f32 = @floatFromInt(rl.getRandomValue(0, width_int));
        if (other == 0) {
            return .{ .x = x, .y = 0 };
        } else {
            return .{ .x = x, .y = height };
        }
    } else {
        const y: f32 = @floatFromInt(rl.getRandomValue(0, height_int));
        if (other == 0) {
            return .{ .x = 0, .y = y };
        } else {
            return .{ .x = width, .y = y };
        }
    }
}

pub fn angle_from_gamepad(x: f32, y: f32) f32 {
    const angle: f32 = math.radiansToDegrees(math.atan2(y, x));
    return angle;
}

pub fn move_towards(object: *obj.Drawable, target: *obj.Drawable, speed: f32) void {
    const dif_x = target.rect_dest.x - object.rect_dest.x;
    const dif_y = target.rect_dest.y - object.rect_dest.y;

    const angle: f32 = math.radiansToDegrees(math.atan2(dif_y, dif_x));

    const move = get_angle_movement(speed, angle);

    object.rect_dest.x += move.x;
    object.rect_dest.y += move.y;
}

pub fn rotate_rect_around_origin(rect: *obj.Drawable, origin_x: f32, origin_y: f32) void {
    if (rect.facing >= 360) {
        rect.facing -= 360;
    }
    const angle = math.degreesToRadians(rect.facing);

    const dif_x = rect.rect_dest.x - origin_x;
    const dif_y = rect.rect_dest.y - origin_y;

    rect.rect_dest.x = (math.cos(angle) * dif_x) - (math.sin(angle) * dif_y) + origin_x;
    rect.rect_dest.y = (math.sin(angle) * dif_x) + (math.cos(angle) * dif_y) + origin_y;
}
