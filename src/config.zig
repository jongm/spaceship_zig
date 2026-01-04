const obj = @import("objects.zig");
const rl = @import("raylib");

pub const GameStatus = enum {
    gameplay,
    pause,
    game_lost,
    game_won,
};

pub const GameState = struct {
    player: *obj.Player,
    bullets: []obj.Bullet,
    enemies: []obj.Enemy,
    sword: *obj.Sword,
    spawn_timer: *u32,
    game_config: *const GameConfig,
    game_status: *GameStatus,
};

pub const GameConfig = struct {
    screen_width: f32,
    screen_height: f32,
    spawn_delay: u32,
};

pub const WheelConfig = struct {
    start_x: f32,
    start_y: f32,
    up_texture: rl.Texture,
    // down_texture: rl.Texture,
    left_texture: rl.Texture,
    right_texture: rl.Texture,
    r1_texture: rl.Texture,
    r2_texture: rl.Texture,
    l1_texture: rl.Texture,
    l2_texture: rl.Texture,
    circle_side: f32,
    circle_gap: f32,
    tex_w: f32,
    tex_h: f32,
};

pub const PlayerConfig = struct {
    tex_x: f32,
    tex_y: f32,
    tex_w: f32,
    tex_h: f32,
    start_x: f32,
    start_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    health: u32,
    texture: rl.Texture,
    death_sound: rl.Sound,
};

pub const EnemyConfig = struct {
    tex_x: f32,
    tex_y: f32,
    tex_w: f32,
    tex_h: f32,
    width: f32,
    height: f32,
    speed: f32,
    health: u32,
    shoot_delay: u32,
    move_delay: u32,
    texture: rl.Texture,
    death_sound: rl.Sound,
};

pub const BulletConfig = struct {
    width: f32,
    height: f32,
    speed: f32,
    tex_x: f32,
    tex_y: f32,
    tex_w: f32,
    tex_h: f32,
    texture: rl.Texture,
    sound: rl.Sound,
};

pub const SwordConfig = struct {
    width: f32,
    height: f32,
    speed: f32,
    tex_x: f32,
    tex_y: f32,
    tex_w: f32,
    tex_h: f32,
    gap: f32,
    texture: rl.Texture,
    sound: rl.Sound,
};
