const rl = @import("raylib");
const con = @import("config.zig");
const uti = @import("utils.zig");
const obj = @import("objects.zig");
const std = @import("std");

pub const SkillWheel = struct {
    rect_up: obj.Drawable,
    rect_down: obj.Drawable,
    rect_left: obj.Drawable,
    rect_right: obj.Drawable,

    pub fn init(config: con.WheelConfig) @This() {
        const rect_source = rl.Rectangle.init(
            0,
            0,
            config.tex_w,
            config.tex_h,
        );

        const rect_dest_up = rl.Rectangle.init(
            config.start_x + config.circle_side + config.circle_gap,
            config.start_y,
            config.circle_side,
            config.circle_side,
        );

        const rect_dest_down = rl.Rectangle.init(
            config.start_x + config.circle_side + config.circle_gap,
            config.start_y + config.circle_side * 2 + config.circle_gap * 2,
            config.circle_side,
            config.circle_side,
        );

        const rect_dest_left = rl.Rectangle.init(
            config.start_x,
            config.start_y + config.circle_side + config.circle_gap,
            config.circle_side,
            config.circle_side,
        );

        const rect_dest_right = rl.Rectangle.init(
            config.start_x + config.circle_side * 2 + config.circle_gap * 2,
            config.start_y + config.circle_side + config.circle_gap,
            config.circle_side,
            config.circle_side,
        );

        return .{
            .rect_up = .{
                .rect_dest = rect_dest_up,
                .rect_source = rect_source,
                .texture = config.up_texture,
                .facing = 0,
            },
            .rect_down = .{
                .rect_dest = rect_dest_down,
                .rect_source = rect_source,
                .texture = config.down_texture,
                .facing = 0,
            },
            .rect_left = .{
                .rect_dest = rect_dest_left,
                .rect_source = rect_source,
                .texture = config.left_texture,
                .facing = 0,
            },
            .rect_right = .{
                .rect_dest = rect_dest_right,
                .rect_source = rect_source,
                .texture = config.right_texture,
                .facing = 0,
            },
        };
    }

    pub fn draw(self: @This()) void {
        uti.draw_object(self.rect_up);
        uti.draw_object(self.rect_down);
        uti.draw_object(self.rect_left);
        uti.draw_object(self.rect_right);
    }
};
