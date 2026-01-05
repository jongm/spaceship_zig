const rl = @import("raylib");
const con = @import("config.zig");
const uti = @import("utils.zig");
const obj = @import("objects.zig");
const std = @import("std");

pub const SkillWheel = struct {
    rect_up: obj.Drawable,
    // rect_down: obj.Drawable,
    rect_left: obj.Drawable,
    rect_right: obj.Drawable,
    rect_l1: obj.Drawable,
    rect_l2: obj.Drawable,
    rect_r1: obj.Drawable,
    rect_r2: obj.Drawable,

    pub fn init(config: con.WheelConfig) @This() {
        const rect_source = rl.Rectangle.init(
            0,
            0,
            config.tex_w,
            config.tex_h,
        );

        const rect_dest_l1 = rl.Rectangle.init(
            config.start_x,
            config.start_y + config.circle_side + config.circle_gap,
            config.circle_side,
            config.circle_side,
        );

        const rect_dest_l2 = rl.Rectangle.init(
            config.start_x,
            config.start_y,
            config.circle_side,
            config.circle_side,
        );

        const rect_dest_r1 = rl.Rectangle.init(
            config.start_x + config.circle_side * 2 + config.circle_gap * 2,
            config.start_y + config.circle_side + config.circle_gap,
            config.circle_side,
            config.circle_side,
        );

        const rect_dest_r2 = rl.Rectangle.init(
            config.start_x + config.circle_side * 2 + config.circle_gap * 2,
            config.start_y,
            config.circle_side,
            config.circle_side,
        );

        const rect_dest_up = rl.Rectangle.init(
            config.start_x + config.circle_side + config.circle_gap,
            config.start_y + config.circle_side + config.circle_gap,
            config.circle_side,
            config.circle_side,
        );

        // const rect_dest_down = rl.Rectangle.init(
        //     config.start_x + config.circle_side + config.circle_gap,
        //     config.start_y + config.circle_side * 3 + config.circle_gap * 1,
        //     config.circle_side,
        //     config.circle_side,
        // );

        const rect_dest_left = rl.Rectangle.init(
            config.start_x + config.circle_side / 2 + config.circle_gap,
            config.start_y + config.circle_side * 2 + config.circle_gap * 2,
            config.circle_side,
            config.circle_side,
        );

        const rect_dest_right = rl.Rectangle.init(
            config.start_x + config.circle_side * 1.5 + config.circle_gap,
            config.start_y + config.circle_side * 2 + config.circle_gap * 2,
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
            // .rect_down = .{
            //     .rect_dest = rect_dest_down,
            //     .rect_source = rect_source,
            //     .texture = config.down_texture,
            //     .facing = 0,
            // },
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
            .rect_l1 = .{
                .rect_dest = rect_dest_l1,
                .rect_source = rect_source,
                .texture = config.l1_texture,
                .facing = 0,
            },
            .rect_l2 = .{
                .rect_dest = rect_dest_l2,
                .rect_source = rect_source,
                .texture = config.l2_texture,
                .facing = 0,
            },
            .rect_r1 = .{
                .rect_dest = rect_dest_r1,
                .rect_source = rect_source,
                .texture = config.r1_texture,
                .facing = 0,
            },
            .rect_r2 = .{
                .rect_dest = rect_dest_r2,
                .rect_source = rect_source,
                .texture = config.r2_texture,
                .facing = 0,
            },
        };
    }

    pub fn draw(self: @This(), state: con.GameState) void {
        uti.draw_object(self.rect_up);
        // uti.draw_object(self.rect_down);
        uti.draw_object(self.rect_left);
        uti.draw_object(self.rect_right);
        uti.draw_object(self.rect_l1);
        uti.draw_object(self.rect_l2);
        uti.draw_object(self.rect_r1);
        uti.draw_object(self.rect_r2);

        if (state.player.skill2.timer < state.player.skill2.cooldown) {
            const rect = self.rect_r1.rect_dest;
            const center = rl.Vector2{
                .x = rect.x + rect.width / 2,
                .y = rect.y + rect.height / 2,
            };
            const ready: f32 = @as(f32, @floatFromInt(state.player.skill2.timer)) / @as(f32, @floatFromInt(state.player.skill2.cooldown));
            const end_angle = 360.0 * ready - 90.0;
            rl.drawRing(
                center,
                0,
                rect.width / 2,
                270.0,
                end_angle,
                0,
                rl.colorAlpha(rl.Color.black, 0.7),
            );
        }

        if (state.player.skill3.timer < state.player.skill3.cooldown) {
            const rect = self.rect_r2.rect_dest;
            const center = rl.Vector2{
                .x = rect.x + rect.width / 2,
                .y = rect.y + rect.height / 2,
            };
            const ready: f32 = @as(f32, @floatFromInt(state.player.skill3.timer)) / @as(f32, @floatFromInt(state.player.skill3.cooldown));
            const end_angle = 360.0 * ready - 90.0;
            rl.drawRing(
                center,
                0,
                rect.width / 2,
                270.0,
                end_angle,
                0,
                rl.colorAlpha(rl.Color.black, 0.7),
            );
        }
    }
};
