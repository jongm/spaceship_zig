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

pub const Animation = struct {
    drawable: Drawable,
    frames: f32,
    cols: f32,
    rows: f32,
    frame_len: u32,
    timer: u32 = 0,
    frame: f32 = 0,

    pub fn update(self: *@This()) void {
        self.timer += 1;
        if (self.timer >= self.frame_len) {
            self.frame += 1;
            self.timer = 0;
            if (self.frame == self.frames) {
                self.frame = 0;
            }
            const col = @mod(self.frame, self.cols);
            const row = @divFloor(self.frame, self.cols);
            const new_x = self.drawable.rect_source.width * col;
            const new_y = self.drawable.rect_source.height * row;
            self.drawable.rect_source.x = new_x;
            self.drawable.rect_source.y = new_y;
        }
    }
};

// Smart array that only grows in size when all elements are active
pub fn MaxArray(T: type) type {
    return struct {
        list: []T,
        max: usize = 0,

        pub fn add(self: *@This(), item: T) void {
            for (0..self.max) |i| {
                if (!self.list[i].active) {
                    self.list[i] = item;
                    return;
                }
            }
            if (self.max < self.list.len) {
                self.list[self.max] = item;
                self.max += 1;
            }
        }
    };
}

pub const damage_status = enum {
    normal,
    shielded,
    damaged,
};

pub const player_effect = enum {
    none,
    speedboost,
};

pub const Player = struct {
    drawable: Drawable,
    speed: f32,
    health: u32,
    score: u32,
    immune: bool,
    immune_timer: u32 = 0,
    dmg_status: damage_status = .normal,
    effect: player_effect = .none,
    effect_timer: u32 = 0,
    effect_animation: Animation = undefined,
    skills: []ski.Skill = undefined,

    pub fn init(config: con.EntityConfig) @This() {
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
            .immune = false,
        };
    }

    pub fn update(self: *@This(), state: con.GameState) void {
        if (self.health == 0) {
            self.die(state);
        }
        for (self.skills) |*skill| {
            if (skill.toggled) {
                skill.use(skill, state);
            }
        }
        switch (self.dmg_status) {
            .shielded => {
                self.immune_timer -|= 1;
                if (self.immune_timer == 0) {
                    self.immune = false;
                    self.dmg_status = .normal;
                }
            },
            .damaged => {
                self.immune_timer -|= 1;
                if (self.immune_timer == 0) {
                    self.immune = false;
                    self.dmg_status = .normal;
                }
            },
            else => {},
        }
        switch (self.effect) {
            .speedboost => {
                self.effect_timer -|= 1;
                if (self.effect_timer == 0) {
                    self.effect = .none;
                    self.speed = val.player_config.speed;
                }
                self.effect_animation.drawable.rect_dest.x = self.drawable.rect_dest.x;
                self.effect_animation.drawable.rect_dest.y = self.drawable.rect_dest.y;
                self.effect_animation.drawable.facing = self.drawable.facing;
                self.effect_animation.update();
            },
            else => {},
        }
    }

    pub fn draw(self: @This()) void {
        uti.draw_object(self.drawable);
        switch (self.dmg_status) {
            .shielded => {
                uti.draw_circle_around(
                    self.drawable,
                    0.8,
                    rl.colorAlpha(rl.Color.blue, 0.0),
                    rl.colorAlpha(rl.Color.sky_blue, 0.8),
                );
            },
            .damaged => {
                uti.draw_circle_around(
                    self.drawable,
                    0.6,
                    rl.colorAlpha(rl.Color.orange, 0.0),
                    rl.colorAlpha(rl.Color.red, 0.8),
                );
            },
            else => {},
        }
        switch (self.effect) {
            .speedboost => {
                uti.draw_object(self.effect_animation.drawable);
            },
            else => {},
        }
    }

    pub fn get_damage(self: *@This(), dmg: u32) void {
        if (!self.immune) {
            self.health -|= dmg;
            self.immune = true;
            self.immune_timer = 60;
            self.dmg_status = .damaged;
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
    active: bool = false,
    sword_dmg_id: u32 = 0,
    scoring: u32,

    pub fn init(config: con.EntityConfig, facing: f32, start_x: f32, start_y: f32) @This() {
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
            .active = true,
            .scoring = config.scoring,
        };
    }

    pub fn update(self: *@This(), state: con.GameState) void {
        if (self.active) {
            uti.move_towards(&self.drawable, &state.player.drawable, self.speed);
            if (rl.checkCollisionRecs(self.drawable.rect_dest, state.player.drawable.rect_dest)) {
                state.player.get_damage(self.damage);
                if (!state.player.immune) {
                    self.active = false;
                }
            }
            if (self.health == 0) {
                self.die(state);
            }
        }
    }

    pub fn spawn(state: con.GameState, config: con.EntityConfig) void {
        const position = uti.get_random_border_position(
            val.game_config.map_width,
            val.game_config.map_height,
        );
        const new_enemy = Enemy.init(
            config,
            0.0,
            position.x,
            position.y,
        );
        state.enemies.add(new_enemy);
    }

    pub fn die(self: *@This(), state: con.GameState) void {
        self.active = false;
        state.player.score += self.scoring;
        // rl.playSound(val.enemy_config.death_sound);
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            uti.draw_object(self.drawable);
        }
    }
};

pub const BulletBomb = struct {
    drawable: Drawable,
    speed: f32,
    active: bool,
    damage: u32,

    pub fn init(config: con.EntityConfig, x: f32, y: f32, facing: f32) @This() {
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
            .damage = config.damage,
        };
    }

    pub fn update(self: *@This(), state: con.GameState) void {
        if (self.active) {
            const moves = uti.get_angle_movement(self.speed, self.drawable.facing - 90);
            self.drawable.rect_dest.x += moves.x;
            self.drawable.rect_dest.y += moves.y;
            if (uti.is_far_from_rect(self.drawable.rect_dest, state.player.drawable.rect_dest, val.game_config.max_bullet_distance)) {
                self.active = false;
            }
            for (0..state.enemies.max) |i| {
                const enemy = &state.enemies.list[i];
                if (enemy.active) {
                    if (rl.checkCollisionRecs(enemy.drawable.rect_dest, self.drawable.rect_dest)) {
                        enemy.health -|= self.damage;
                        self.explode(state);
                    }
                }
            }
        }
    }

    pub fn explode(self: *@This(), state: con.GameState) void {
        self.active = false;
        const amount = 24;
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
    damage: u32,

    pub fn init(config: con.EntityConfig, x: f32, y: f32, facing: f32) @This() {
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
            .damage = config.damage,
        };
    }

    pub fn update(self: *@This(), state: con.GameState) void {
        if (self.active) {
            const moves = uti.get_angle_movement(self.speed, self.drawable.facing - 90);
            self.drawable.rect_dest.x += moves.x;
            self.drawable.rect_dest.y += moves.y;
            if (uti.is_far_from_rect(self.drawable.rect_dest, state.player.drawable.rect_dest, val.game_config.max_bullet_distance)) {
                self.active = false;
            }
            for (0..state.enemies.max) |i| {
                const enemy = &state.enemies.list[i];
                if (enemy.active) {
                    if (rl.checkCollisionRecs(enemy.drawable.rect_dest, self.drawable.rect_dest)) {
                        enemy.health -|= self.damage;
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
    dmg_id: u32,
    damage: u32,

    pub var sword_id: u32 = 1;

    pub fn init(config: con.EntityConfig, origin: Drawable) @This() {
        var sword: @This() = .{
            .rects = undefined,
            .speed = config.speed,
            .active = true,
            .travelled = 0,
            .gap = config.gap,
            .damage = config.damage,
            .dmg_id = sword_id,
        };
        sword_id += 1;
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
                if (enemy.active) {
                    for (self.rects) |rect| {
                        if (rl.checkCollisionRecs(enemy.drawable.rect_dest, rect.rect_dest)) {
                            if (enemy.sword_dmg_id < self.dmg_id) {
                                enemy.health -|= self.damage;
                                enemy.sword_dmg_id = self.dmg_id;
                            }
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

pub const Portal = struct {
    animation: Animation,
    active: bool,
    damage: u32,

    pub fn init(config: con.EntityConfig, x: f32, y: f32) @This() {
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
            .animation = .{
                .drawable = .{
                    .rect_dest = rect_dest,
                    .rect_source = rect_source,
                    .texture = config.texture,
                    .facing = 0,
                },
                .cols = config.frame_cols,
                .rows = config.frame_rows,
                .frames = config.frames,
                .frame_len = config.frame_len,
                .timer = 0,
            },
            .active = true,
            .damage = config.damage,
        };
    }

    pub fn update(self: *@This(), state: con.GameState) void {
        if (self.active) {
            self.animation.update();
            for (0..state.enemies.max) |i| {
                const enemy = &state.enemies.list[i];
                if (enemy.active) {
                    if (rl.checkCollisionRecs(enemy.drawable.rect_dest, self.animation.drawable.rect_dest)) {
                        enemy.health -|= self.damage;
                        if (enemy.health == 0) {
                            enemy.die(state);
                        }
                    }
                }
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            uti.draw_object(self.animation.drawable);
        }
    }
};
