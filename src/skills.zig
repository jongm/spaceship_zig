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
        state.player.dmg_status = .shielded;
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

pub fn use_portal(self: *Skill, state: con.GameState) void {
    if (self.timer >= self.cooldown) {
        const pos_x = state.player.drawable.rect_dest.x + 150;
        const pos_y = state.player.drawable.rect_dest.y;
        const new_portal = obj.Portal.init(
            val.portal_config,
            pos_x,
            pos_y,
        );
        state.portal.* = new_portal;
        self.timer = 0;
    }
}

pub var portal_skill = Skill{
    .cooldown = 200,
    .timer = 200,
    .icon = undefined,
    .use = use_portal,
};

pub fn use_speedboost(self: *Skill, state: con.GameState) void {
    if (self.timer >= self.cooldown) {
        state.player.effect = .speedboost;
        state.player.effect_timer = 120;
        state.player.speed += 10;
        self.timer = 0;
        state.player.effect_animation = obj.Animation{
            .drawable = .{
                .rect_source = .{
                    .x = val.speedboost_config.tex_x,
                    .y = val.speedboost_config.tex_y,
                    .width = val.speedboost_config.tex_w,
                    .height = val.speedboost_config.tex_h,
                },
                .rect_dest = .{
                    .x = state.player.drawable.rect_dest.x,
                    .y = state.player.drawable.rect_dest.y,
                    .width = state.player.drawable.rect_dest.width * 1.2,
                    .height = state.player.drawable.rect_dest.height * 1.2,
                },
                .texture = val.speedboost_config.texture,
                .facing = state.player.drawable.facing,
            },
            .cols = val.speedboost_config.frame_cols,
            .rows = val.speedboost_config.frame_rows,
            .frame_len = val.speedboost_config.frame_len,
            .frames = val.speedboost_config.frames,
            .frame = 0,
            .timer = 0,
        };
    }
}

pub var speedboost_skill = Skill{
    .cooldown = 500,
    .timer = 500,
    .icon = undefined,
    .use = use_speedboost,
};
