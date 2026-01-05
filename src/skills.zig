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
            for (0..state.bullets.max + 1) |i| {
                const bullet = &state.bullets.list[i];
                if (!bullet.active) {
                    const new_bullet = obj.Bullet.init(
                        val.bullet_config,
                        state.player.drawable.rect_dest.x + state.player.drawable.rect_dest.width / 2,
                        state.player.drawable.rect_dest.y + state.player.drawable.rect_dest.height / 2,
                        state.player.drawable.facing,
                    );
                    state.bullets.list[i] = new_bullet;
                    if (i == state.bullets.max) {
                        state.bullets.max += 1;
                    }
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

pub const ShieldSkill = struct {
    cooldown: u32,
    timer: u32,
    icon: rl.Texture,

    pub fn use(self: *@This(), state: con.GameState) void {
        if (self.timer >= self.cooldown) {
            state.player.immune = true;
            state.player.immune_timer = 120;
            state.player.effect = .shielded;
            self.timer = 0;
            // rl.playSound(val.sword_config.sound);
        }
    }
};

pub const BulletBombSkill = struct {
    cooldown: u32,
    timer: u32,
    icon: rl.Texture,

    pub fn use(self: *@This(), state: con.GameState) void {
        if (self.timer >= self.cooldown) {
            const new_bullet_bomb = obj.BulletBomb.init(
                val.bullet_bomb_config,
                state.player.drawable.rect_dest.x + state.player.drawable.rect_dest.width / 2,
                state.player.drawable.rect_dest.y + state.player.drawable.rect_dest.height / 2,
                state.player.drawable.facing,
            );
            state.bomb.* = new_bullet_bomb;
            self.timer = 0;
            rl.playSound(val.bullet_config.sound);
        }
    }
};
