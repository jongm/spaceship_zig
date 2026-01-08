const rl = @import("raylib");
const con = @import("config.zig");
const uti = @import("utils.zig");
const val = @import("values.zig");
const obj = @import("objects.zig");
const std = @import("std");

pub const SkillWheel = struct {
    rect_source: rl.Rectangle,
    rects_dest: [7]rl.Rectangle,
    circle_texture: rl.Texture,

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
            .rect_source = rect_source,
            .rects_dest = .{
                rect_dest_left,
                rect_dest_up,
                rect_dest_right,
                rect_dest_r1,
                rect_dest_r2,
                rect_dest_l1,
                rect_dest_l2,
            },
            .circle_texture = config.circle_texture,
        };
    }

    pub fn draw(self: @This(), state: con.GameState) void {
        for (state.player.skills, 0..) |skill, i| {
            uti.draw_object(.{
                .rect_source = .{
                    .x = skill.icon_config.tex_x,
                    .y = skill.icon_config.tex_y,
                    .width = skill.icon_config.tex_w,
                    .height = skill.icon_config.tex_h,
                },
                .rect_dest = .{
                    .x = self.rects_dest[i].x + 15,
                    .y = self.rects_dest[i].y + 15,
                    .width = val.wheel_config.circle_side / 2,
                    .height = val.wheel_config.circle_side / 2,
                },
                .texture = skill.icon_config.texture,
                .facing = 45,
            });

            for (self.rects_dest) |dest| {
                uti.draw_object(.{
                    .rect_source = self.rect_source,
                    .rect_dest = dest,
                    .texture = self.circle_texture,
                    .facing = 0,
                });
            }

            if (!skill.is_toggled) {
                if (skill.timer < skill.cooldown) {
                    const rect = self.rects_dest[i];
                    const center = rl.Vector2{
                        .x = rect.x + rect.width / 2,
                        .y = rect.y + rect.height / 2,
                    };
                    const ready: f32 = @as(f32, @floatFromInt(skill.timer)) / @as(f32, @floatFromInt(skill.cooldown));
                    const end_angle = 360.0 * ready - 90.0;
                    rl.drawRing(
                        center,
                        0,
                        rect.width / 2,
                        270.0,
                        end_angle,
                        0,
                        rl.colorAlpha(rl.Color.red, 0.7),
                    );
                }
            }
        }
    }
};
