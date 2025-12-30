pub const GameConfig = struct {
    screen_width: f32,
    screen_height: f32,
    spawn_delay: u32,
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
    rotation_speed: f32,
};

pub const EnemyConfig = struct {
    tex_x: f32,
    tex_y: f32,
    tex_w: f32,
    tex_h: f32,
    width: f32,
    height: f32,
    speed: f32,
    rotation_speed: f32,
    shoot_delay: u32,
    move_delay: u32,
};

pub const BulletConfig = struct {
    width: f32,
    height: f32,
    speed: f32,
    tex_x: f32,
    tex_y: f32,
    tex_w: f32,
    tex_h: f32,
};
