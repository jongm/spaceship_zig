const con = @import("config.zig");

pub const game_config = con.GameConfig{
    .screen_width = 1600,
    .screen_height = 1000,
    .spawn_delay = 30,
    .rotation_speed = 50,
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
};

pub var enemy_config = con.EnemyConfig{
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 402,
    .tex_h = 272,
    .width = 90,
    .height = 61,
    .speed = 5,
    .rotation_speed = 5,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
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
};
