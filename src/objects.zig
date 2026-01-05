const rl = @import("raylib");
const con = @import("config.zig");
const uti = @import("utils.zig");
const val = @import("values.zig");
const ski = @import("skills.zig");
const std = @import("std");
const math = std.math;

pub const Drawable = struct {
    rect_source: rl.Rectangle,
    rect_dest: rl.Rectangle,
    texture: rl.Texture,
    facing: f32,
};

pub fn MaxArray(T: type) type {
    return struct {
        list: []T,
        max: usize = 1,
    };
}

pub const player_effect = enum {
    normal,
    shielded,
    damaged,
};

pub const Player = struct {
    drawable: Drawable,
    speed: f32,
    health: u32,
    score: u32,
    immune: bool,
    immune_timer: u32 = 0,
    effect: player_effect = .normal,
    skill1_toggled: bool,
    skill1: *ski.BulletSkill = undefined,
    skill2: *ski.SwordSkill = undefined,
    skill3: *ski.BulletBombSkill = undefined,
    skill4: *ski.ShieldSkill = undefined,

    pub fn init(config: con.PlayerConfig) @This() {
        const rect_source = rl.Rectangle.init(
            config.tex_x,
            config.tex_y,
            config.tex_w,
            config.tex_h,
        );
        const rect_dest = rl.Rectangle.init(
            config.start_x,
            config.start_y,
            config.width,
            config.height,
        );
        return .{
            .drawable = .{
                .rect_source = rect_source,
                .rect_dest = rect_dest,
                .texture = config.texture,
                .facing = 0.0,
            },
            .speed = config.speed,
            .health = config.health,
            .score = 0,
            .skill1_toggled = false,
            .immune = false,
        };
    }

    pub fn update(self: *@This(), state: con.GameState) void {
        if (self.health == 0) {
            self.die(state);
        }
        if (self.skill1_toggled) {
            self.skill1.use(state);
        }
        switch (self.effect) {
            .shielded => {
                self.immune_timer -|= 1;
                if (self.immune_timer == 0) {
                    self.immune = false;
                    self.effect = .normal;
                }
            },
            .damaged => {
                self.immune_timer -|= 1;
                if (self.immune_timer == 0) {
                    self.immune = false;
                    self.effect = .normal;
                }
            },
            else => {},
        }
    }

    pub fn draw(self: @This()) void {
        uti.draw_object(self.drawable);
        switch (self.effect) {
            .shielded => {
                uti.draw_shield(self.drawable);
            },
            .damaged => {
                uti.draw_damaged(self.drawable);
            },
            else => {},
        }
    }

    pub fn get_damage(self: *@This(), dmg: u32) void {
        if (!self.immune) {
            self.health -|= dmg;
            self.immune = true;
            self.immune_timer = 60;
            self.effect = .damaged;
        }
    }

    pub fn die(self: *@This(), state: con.GameState) void {
        self.health = 0;
        rl.playSound(val.player_config.death_sound);
        state.game_status.* = .game_lost;
    }
};

pub const Enemy = struct {
    drawable: Drawable,
    speed: f32,
    move_delay: u32,
    shoot_delay: u32,
    health: u32,
    damage: u32,
    move_timer: u32 = 0,
    shoot_timer: u32 = 0,
    alive: bool = false,

    pub fn init(config: con.EnemyConfig, facing: f32, start_x: f32, start_y: f32) @This() {
        const rect_source = rl.Rectangle.init(
            config.tex_x,
            config.tex_y,
            config.tex_w,
            config.tex_h,
        );
        const rect_dest = rl.Rectangle.init(
            start_x,
            start_y,
            config.width,
            config.height,
        );
        return .{
            .drawable = .{
                .rect_source = rect_source,
                .rect_dest = rect_dest,
                .texture = config.texture,
                .facing = facing,
            },
            .speed = config.speed,
            .move_delay = config.move_delay,
            .shoot_delay = config.shoot_delay,
            .health = config.health,
            .damage = config.damage,
        };
    }

    pub fn update(self: *@This(), state: con.GameState) void {
        if (self.alive) {
            uti.move_towards(&self.drawable, &state.player.drawable, self.speed);
            if (rl.checkCollisionRecs(self.drawable.rect_dest, state.player.drawable.rect_dest)) {
                state.player.get_damage(self.damage);
                if (!state.player.immune) {
                    self.alive = false;
                }
            }
            if (self.health == 0) {
                self.die(state);
            }
        }
    }

    pub fn die(self: *@This(), state: con.GameState) void {
        self.alive = false;
        state.player.score += 1;
        rl.playSound(val.enemy_config.death_sound);
    }

    pub fn draw(self: @This()) void {
        if (self.alive) {
            uti.draw_object(self.drawable);
        }
    }
};

pub const BulletBomb = struct {
    drawable: Drawable,
    speed: f32,
    active: bool,

    pub fn init(config: con.BulletConfig, x: f32, y: f32, facing: f32) @This() {
        const rect_source = rl.Rectangle.init(
            config.tex_x,
            config.tex_y,
            config.tex_w,
            config.tex_h,
        );
        const rect_dest = rl.Rectangle.init(
            x,
            y,
            config.width,
            config.height,
        );
        return .{
            .drawable = .{
                .rect_dest = rect_dest,
                .rect_source = rect_source,
                .texture = config.texture,
                .facing = facing,
            },
            .speed = config.speed,
            .active = true,
        };
    }

    pub fn update(self: *@This(), state: con.GameState) void {
        if (self.active) {
            const moves = uti.get_angle_movement(self.speed, self.drawable.facing - 90);
            self.drawable.rect_dest.x += moves.x;
            self.drawable.rect_dest.y += moves.y;
            if (self.drawable.rect_dest.x <= 0 or self.drawable.rect_dest.x >= state.game_config.screen_width or self.drawable.rect_dest.y <= 0 or self.drawable.rect_dest.y >= state.game_config.screen_height) {
                self.active = false;
            }
            for (0..state.enemies.max) |i| {
                const enemy = &state.enemies.list[i];
                if (enemy.alive) {
                    if (rl.checkCollisionRecs(enemy.drawable.rect_dest, self.drawable.rect_dest)) {
                        self.explode(state);
                    }
                }
            }
        }
    }

    pub fn explode(self: *@This(), state: con.GameState) void {
        self.active = false;
        const amount = 16;
        for (0..amount) |i| {
            const bomb_bullet = &state.bomb_bullets.list[i];
            const facing: f32 = @floatFromInt(i * (360 / amount));
            if (!bomb_bullet.active) {
                const new_bullet = Bullet.init(
                    val.bullet_bomb_bullet_config,
                    self.drawable.rect_dest.x + self.drawable.rect_dest.width / 2,
                    self.drawable.rect_dest.y + self.drawable.rect_dest.height / 2,
                    facing,
                );
                state.bomb_bullets.list[i] = new_bullet;
                state.bomb_bullets.max = amount + 1;
                rl.playSound(val.bullet_config.sound);
                std.debug.print("Created bullet {d}\n", .{i});
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            uti.draw_object(self.drawable);
        }
    }
};

pub const Bullet = struct {
    drawable: Drawable,
    speed: f32,
    active: bool,

    pub fn init(config: con.BulletConfig, x: f32, y: f32, facing: f32) @This() {
        const rect_source = rl.Rectangle.init(
            config.tex_x,
            config.tex_y,
            config.tex_w,
            config.tex_h,
        );
        const rect_dest = rl.Rectangle.init(
            x,
            y,
            config.width,
            config.height,
        );
        return .{
            .drawable = .{
                .rect_dest = rect_dest,
                .rect_source = rect_source,
                .texture = config.texture,
                .facing = facing,
            },
            .speed = config.speed,
            .active = true,
        };
    }

    pub fn update(self: *@This(), state: con.GameState) void {
        if (self.active) {
            const moves = uti.get_angle_movement(self.speed, self.drawable.facing - 90);
            self.drawable.rect_dest.x += moves.x;
            self.drawable.rect_dest.y += moves.y;
            if (self.drawable.rect_dest.x <= 0 or self.drawable.rect_dest.x >= state.game_config.screen_width or self.drawable.rect_dest.y <= 0 or self.drawable.rect_dest.y >= state.game_config.screen_height) {
                self.active = false;
            }
            for (0..state.enemies.max) |i| {
                const enemy = &state.enemies.list[i];
                if (enemy.alive) {
                    if (rl.checkCollisionRecs(enemy.drawable.rect_dest, self.drawable.rect_dest)) {
                        enemy.health -|= 1;
                        if (enemy.health == 0) {
                            enemy.die(state);
                        }
                        self.active = false;
                    }
                }
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            uti.draw_object(self.drawable);
        }
    }
};

const sword_rects = 5;
pub const Sword = struct {
    rects: [sword_rects]Drawable,
    speed: f32,
    active: bool,
    travelled: f32,
    gap: f32,

    pub fn init(config: con.SwordConfig, origin: Drawable) @This() {
        var sword: @This() = .{
            .rects = undefined,
            .speed = config.speed,
            .active = true,
            .travelled = 0,
            .gap = config.gap,
        };
        const block_tex_height = config.tex_h / sword_rects;
        const block_dest_height = config.height / sword_rects;
        for (0..sword_rects) |n| {
            const i: f32 = @floatFromInt(n);
            const rect_source = rl.Rectangle.init(
                config.tex_x,
                block_tex_height * i,
                config.tex_w,
                block_tex_height,
            );
            const rect_dest = rl.Rectangle.init(
                origin.rect_dest.x + origin.rect_dest.width / 2 - config.width / 2,
                origin.rect_dest.y + block_dest_height * i - config.gap,
                config.width,
                block_dest_height,
            );
            const rect: Drawable = .{
                .rect_source = rect_source,
                .rect_dest = rect_dest,
                .facing = origin.facing,
                .texture = config.texture,
            };
            sword.rects[n] = rect;
        }

        return sword;
    }

    pub fn update(self: *@This(), origin: Drawable, state: con.GameState) void {
        if (self.active) {
            const center = origin.rect_dest;
            for (&self.rects, 0..) |*rect, n| {
                const i: f32 = @floatFromInt(n);
                rect.rect_dest.x = origin.rect_dest.x + origin.rect_dest.width / 2 - rect.rect_dest.width / 2;
                rect.rect_dest.y = origin.rect_dest.y + rect.rect_dest.height * i - self.gap;
                rect.facing += self.speed;
                uti.rotate_rect_around_origin(
                    rect,
                    center.x + center.width / 2,
                    center.y + center.height / 2,
                );
            }
            for (0..state.enemies.max) |i| {
                const enemy = &state.enemies.list[i];
                if (enemy.alive) {
                    for (self.rects) |rect| {
                        if (rl.checkCollisionRecs(enemy.drawable.rect_dest, rect.rect_dest)) {
                            enemy.health -|= 1;
                        }
                    }
                }
            }
            self.travelled += self.speed;
            if (self.travelled > 360 + self.rects[0].rect_dest.width) {
                self.active = false;
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            for (self.rects) |rect| {
                uti.draw_object(rect);
            }
        }
    }
};
