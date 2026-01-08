const con = @import("config.zig");

const tile_width: f32 = 1024;
const tile_height: f32 = 1024;
const bg_cols: usize = 3;
const bg_rows: usize = 3;

pub const game_config = con.GameConfig{
    .screen_width = 1600,
    .screen_height = 1000,
    .spawn_delay_e1 = 50,
    .spawn_delay_e2 = 80,
    .spawn_delay_e3 = 250,
    .spawn_delay_e4 = 500,
    .max_bullet_distance = 2000,
    .tile_width = tile_width,
    .tile_height = tile_height,
    .bg_cols = bg_cols,
    .bg_rows = bg_rows,
    .map_width = tile_width * bg_cols,
    .map_height = tile_height * bg_rows,
};

pub var wheel_config = con.WheelConfig{
    .start_x = 50,
    .start_y = game_config.screen_height - 300,
    .tex_w = 157,
    .tex_h = 172,
    .circle_texture = undefined,
    .circle_side = 70,
    .circle_gap = 5,
};

pub var player_config = con.EntityConfig{
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 242, //392,
    .tex_h = 187, //338,
    .start_x = game_config.map_width / 2,
    .start_y = game_config.map_height / 2,
    .width = 70,
    .height = 70,
    .speed = 10,
    .health = 5,
    .texture = undefined,
    .death_sound = undefined,
};

pub var bullet_config = con.EntityConfig{
    .height = 30,
    .width = 20,
    .speed = 20,
    .tex_x = 69,
    .tex_y = 225,
    .tex_w = 10,
    .tex_h = 20,
    .damage = 1,
    .texture = undefined,
    .sound = undefined,
};

pub var bullet_bomb_config = con.EntityConfig{
    .height = 59,
    .width = 43,
    .speed = 10,
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 86,
    .tex_h = 118,
    .damage = 10,
    .texture = undefined,
    .sound = undefined,
};

pub var bullet_bomb_bullet_config = con.EntityConfig{
    .height = 35,
    .width = 22,
    .speed = 20,
    .tex_x = 8,
    .tex_y = 225,
    .tex_w = 10,
    .tex_h = 20,
    .damage = 3,
    .texture = undefined,
    .sound = undefined,
};

pub var sword_config = con.EntityConfig{
    .height = 225,
    .width = 30,
    .speed = 12,
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 80,
    .tex_h = 297,
    .gap = 200,
    .damage = 5,
    .texture = undefined,
    .sound = undefined,
};

pub var portal_config = con.EntityConfig{
    .height = 120,
    .width = 120,
    .tex_x = 0,
    .tex_y = 0,
    .tex_h = 64,
    .tex_w = 64,
    .damage = 1,
    .frame_cols = 4,
    .frame_rows = 2,
    .frames = 7,
    .frame_len = 5,
    .texture = undefined,
    .sound = undefined,
};

pub var shield_config = con.EntityConfig{
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 114,
    .tex_h = 114,
    .height = 100,
    .width = 100,
    .damage = 120,
    .texture = undefined,
    .sound = undefined,
};

pub var speedboost_config = con.EntityConfig{
    .tex_x = 0,
    .tex_y = 0,
    .tex_h = 128,
    .tex_w = 128,
    .width = 0,
    .height = 0,
    .frame_cols = 5,
    .frame_rows = 2,
    .frames = 8,
    .frame_len = 5,
    .speed = 5, // effect
    .texture = undefined,
    .sound = undefined,
};

// ENEMIES
pub var enemy11_config = con.EntityConfig{
    .tex_x = 36,
    .tex_y = 34,
    .tex_w = 56,
    .tex_h = 51,
    .width = 56 * 1.2,
    .height = 51 * 1.2,
    .speed = 5,
    .health = 1,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 1,
};

pub var enemy12_config = con.EntityConfig{
    .tex_x = 159,
    .tex_y = 16,
    .tex_w = 66 * 1.1,
    .tex_h = 97 * 1.1,
    .width = 66,
    .height = 97,
    .speed = 4,
    .health = 2,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 2,
};

pub var enemy13_config = con.EntityConfig{
    .tex_x = 287,
    .tex_y = 6,
    .tex_w = 66,
    .tex_h = 116,
    .width = 66 * 1.5,
    .height = 116 * 1.5,
    .speed = 4,
    .health = 5,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 3,
};

pub var enemy14_config = con.EntityConfig{
    .tex_x = 403,
    .tex_y = 2,
    .tex_w = 90,
    .tex_h = 123,
    .width = 90 * 2,
    .height = 123 * 2,
    .speed = 3,
    .health = 20,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 5,
};

pub var enemy21_config = con.EntityConfig{
    .tex_x = 30,
    .tex_y = 154,
    .tex_w = 69,
    .tex_h = 76,
    .width = 69,
    .height = 76,
    .speed = 5,
    .health = 1,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 1,
};

pub var enemy22_config = con.EntityConfig{
    .tex_x = 153,
    .tex_y = 153,
    .tex_w = 78,
    .tex_h = 78,
    .width = 78 * 1.1,
    .height = 78 * 1.1,
    .speed = 4,
    .health = 2,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 2,
};

pub var enemy23_config = con.EntityConfig{
    .tex_x = 277,
    .tex_y = 145,
    .tex_w = 86,
    .tex_h = 93,
    .width = 86 * 1.5,
    .height = 93 * 1.5,
    .speed = 4,
    .health = 5,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 3,
};

pub var enemy24_config = con.EntityConfig{
    .tex_x = 403,
    .tex_y = 139,
    .tex_w = 90,
    .tex_h = 107,
    .width = 90 * 2,
    .height = 107 * 2,
    .speed = 3,
    .health = 20,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 5,
};

pub var enemy31_config = con.EntityConfig{
    .tex_x = 31,
    .tex_y = 279,
    .tex_w = 66,
    .tex_h = 82,
    .width = 66,
    .height = 82,
    .speed = 4,
    .health = 1,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 1,
};

pub var enemy32_config = con.EntityConfig{
    .tex_x = 155,
    .tex_y = 270,
    .tex_w = 74,
    .tex_h = 103,
    .width = 74,
    .height = 103,
    .speed = 4,
    .health = 1,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 2,
};

pub var enemy33_config = con.EntityConfig{
    .tex_x = 269,
    .tex_y = 270,
    .tex_w = 102,
    .tex_h = 103,
    .width = 102,
    .height = 103,
    .speed = 4,
    .health = 1,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 3,
};

pub var enemy34_config = con.EntityConfig{
    .tex_x = 397,
    .tex_y = 270,
    .tex_w = 102,
    .tex_h = 103,
    .width = 102,
    .height = 103,
    .speed = 4,
    .health = 1,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 5,
};

pub var enemy41_config = con.EntityConfig{
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 402,
    .tex_h = 272,
    .width = 90,
    .height = 61,
    .speed = 4,
    .health = 1,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 1,
};

pub var enemy42_config = con.EntityConfig{
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 402,
    .tex_h = 272,
    .width = 90,
    .height = 61,
    .speed = 4,
    .health = 1,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 2,
};

pub var enemy43_config = con.EntityConfig{
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 402,
    .tex_h = 272,
    .width = 90,
    .height = 61,
    .speed = 4,
    .health = 1,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 3,
};

pub var enemy44_config = con.EntityConfig{
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 402,
    .tex_h = 272,
    .width = 90,
    .height = 61,
    .speed = 4,
    .health = 1,
    .damage = 1,
    .move_delay = 100,
    .shoot_delay = 200,
    .texture = undefined,
    .death_sound = undefined,
    .scoring = 5,
};
