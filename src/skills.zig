const rl = @import("raylib");
const con = @import("config.zig");
const uti = @import("utils.zig");
const obj = @import("objects.zig");
const val = @import("values.zig");
const std = @import("std");

pub const Skill = struct {
    cooldown: u32,
    timer: u32,
    icon: rl.Texture,
    toggled: bool = false,
    use: *const fn (self: *@This(), state: con.GameState) void,
};

fn use_shoot(self: *Skill, state: con.GameState) void {
    if (self.timer >= self.cooldown) {
        const new_bullet = obj.Bullet.init(
            val.bullet_config,
            state.player.drawable.rect_dest.x + state.player.drawable.rect_dest.width / 2,
            state.player.drawable.rect_dest.y + state.player.drawable.rect_dest.height / 2,
            state.player.drawable.facing,
        );
        state.bullets.add(new_bullet);
        self.timer = 0;
        rl.playSound(val.bullet_config.sound);
    }
}

pub var shoot_skill = Skill{
    .cooldown = 20,
    .timer = 20,
    .icon = undefined,
    .use = use_shoot,
};

pub fn use_sword(self: *Skill, state: con.GameState) void {
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

pub var sword_skill = Skill{
    .cooldown = 150,
    .timer = 150,
    .icon = undefined,
    .use = use_sword,
};

pub fn use_shield(self: *Skill, state: con.GameState) void {
    if (self.timer >= self.cooldown) {
        state.player.immune = true;
        state.player.immune_timer = 120;
        state.player.effect = .shielded;
        self.timer = 0;
        // rl.playSound(val.sword_config.sound);
    }
}

pub var shield_skill = Skill{
    .cooldown = 400,
    .timer = 400,
    .icon = undefined,
    .use = use_shield,
};

pub fn use_bullet_bomb(self: *Skill, state: con.GameState) void {
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

pub var bullet_bomb_skill = Skill{
    .cooldown = 300,
    .timer = 300,
    .icon = undefined,
    .use = use_bullet_bomb,
};
