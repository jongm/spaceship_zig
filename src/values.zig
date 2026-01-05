const con = @import("config.zig");

pub const game_config = con.GameConfig{
    .screen_width = 1600,
    .screen_height = 1000,
    .spawn_delay = 30,
};

pub var wheel_config = con.WheelConfig{
    .start_x = 50,
    .start_y = game_config.screen_height - 300,
    .tex_w = 157,
    .tex_h = 172,
    .up_texture = undefined,
    // .down_texture = undefined,
    .left_texture = undefined,
    .right_texture = undefined,
    .r1_texture = undefined,
    .r2_texture = undefined,
    .l1_texture = undefined,
    .l2_texture = undefined,
    .circle_side = 70,
    .circle_gap = 5,
};

pub var player_config = con.PlayerConfig{
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 392,
    .tex_h = 338,
    .start_x = 820,
    .start_y = 520,
    .width = 60,
    .height = 60,
    .speed = 10,
    .health = 5,
    .texture = undefined,
    .death_sound = undefined,
};

pub var enemy_config = con.EnemyConfig{
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 402,
    .tex_h = 272,
    .width = 90,
    .height = 61,
    .speed = 4,
    .health = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
};

pub var bullet_config = con.BulletConfig{
    .height = 30,
    .width = 20,
    .speed = 20,
    .tex_x = 69,
    .tex_y = 225,
    .tex_w = 10,
    .tex_h = 20,
    .texture = undefined,
    .sound = undefined,
};

pub var bullet_bomb_config = con.BulletConfig{
    .height = 45,
    .width = 30,
    .speed = 10,
    .tex_x = 215,
    .tex_y = 288,
    .tex_w = 10,
    .tex_h = 13,
    .texture = undefined,
    .sound = undefined,
};

pub var bullet_bomb_bullet_config = con.BulletConfig{
    .height = 30,
    .width = 20,
    .speed = 20,
    .tex_x = 8,
    .tex_y = 225,
    .tex_w = 10,
    .tex_h = 20,
    .texture = undefined,
    .sound = undefined,
};

pub var sword_config = con.SwordConfig{
    .height = 150,
    .width = 20,
    .speed = 12,
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 80,
    .tex_h = 297,
    .gap = 200,
    .texture = undefined,
    .sound = undefined,
};
