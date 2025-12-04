const rl = @import("raylib");
const obj = @import("objects.zig");
const std = @import("std");

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
    const rad = std.math.degreesToRadians(angle - 90.0);
    return .{
        .x = std.math.cos(rad) * speed,
        .y = std.math.sin(rad) * speed,
    };
}
