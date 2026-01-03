const rl = @import("raylib");
const con = @import("config.zig");
const uti = @import("utils.zig");
const obj = @import("objects.zig");
const val = @import("values.zig");
const std = @import("std");

pub const BulletSkill = struct {
    cooldown: u32,
    timer: u32,
    icon: rl.Texture,

    pub fn use(self: *@This(), state: con.GameState) void {
        if (self.timer >= self.cooldown) {
            for (state.bullets, 0..) |*bullet, i| {
                if (!bullet.active) {
                    const new_bullet = obj.Bullet.init(
                        val.bullet_config,
                        state.player.drawable.rect_dest.x + state.player.drawable.rect_dest.width / 2,
                        state.player.drawable.rect_dest.y + state.player.drawable.rect_dest.height / 2,
                        state.player.drawable.facing,
                    );
                    state.bullets[i] = new_bullet;
                    self.timer = 0;
                    rl.playSound(val.bullet_config.sound);
                    break;
                }
            }
        }
    }
};

pub const SwordSkill = struct {
    cooldown: u32,
    timer: u32,
    icon: rl.Texture,

    pub fn use(self: *@This(), state: con.GameState) void {
        if (self.timer >= self.cooldown) {
            const new_sword = obj.Sword.init(
                val.sword_config,
                state.player.drawable,
            );
            state.sword.* = new_sword;
            self.timer = 0;
            rl.playSound(val.sword_config.sound);
        }
    }
};
