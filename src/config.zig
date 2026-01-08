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
    bullets: *obj.MaxArray(obj.Bullet),
    bomb_bullets: *obj.MaxArray(obj.Bullet),
    enemies: *obj.MaxArray(obj.Enemy),
    sword: *obj.Sword,
    portal: *obj.Portal,
    bomb: *obj.BulletBomb,
    spawn_timer_e1: *u32,
    spawn_timer_e2: *u32,
    spawn_timer_e3: *u32,
    spawn_timer_e4: *u32,
    game_config: *const GameConfig,
    game_status: *GameStatus,
};

pub const GameConfig = struct {
    screen_width: f32,
    screen_height: f32,
    spawn_delay_e1: u32,
    spawn_delay_e2: u32,
    spawn_delay_e3: u32,
    spawn_delay_e4: u32,
    max_bullet_distance: f32,
    bg_cols: usize,
    bg_rows: usize,
    map_width: f32,
    map_height: f32,
    tile_width: f32,
    tile_height: f32,
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

pub const EntityConfig = struct {
    // Drawable
    tex_x: f32,
    tex_y: f32,
    tex_w: f32,
    tex_h: f32,
    width: f32,
    height: f32,
    texture: rl.Texture,
    gap: f32 = undefined,
    // Animation
    frame_len: u32 = undefined,
    frame_rows: f32 = undefined,
    frame_cols: f32 = undefined,
    frames: f32 = undefined,
    // Effects
    sound: rl.Sound = undefined,
    //Stats
    speed: f32 = undefined,
    health: u32 = undefined,
    // Player
    start_x: f32 = undefined,
    start_y: f32 = undefined,
    // Enemies and attacks
    damage: u32 = undefined,
    scoring: u32 = undefined,
    shoot_delay: u32 = undefined,
    move_delay: u32 = undefined,
    death_sound: rl.Sound = undefined,
};
