const rl = @import("raylib");
const con = @import("config.zig");

pub const Drawable = struct {
    rect_source: rl.Rectangle,
    rect_dest: rl.Rectangle,
    texture: rl.Texture,
    facing: f32,
};

pub const Player = struct {
    drawable: Drawable,
    speed: f32,
    rotation_speed: f32,

    pub fn init(config: con.PlayerConfig, texture: rl.Texture) @This() {
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
                .texture = texture,
                .facing = 0.0,
            },
            .speed = config.speed,
            .rotation_speed = config.rotation_speed,
        };
    }
};

pub const Enemy = struct {
    drawable: Drawable,
    speed: f32,
    rotation_speed: f32,
    move_delay: u32,
    shoot_delay: u32,
    move_timer: u32 = 0,
    shoot_timer: u32 = 0,
    alive: bool = false,

    pub fn init(config: con.EnemyConfig, texture: rl.Texture, facing: f32, start_x: f32, start_y: f32) @This() {
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
                .texture = texture,
                .facing = facing,
            },
            .speed = config.speed,
            .rotation_speed = config.rotation_speed,
            .move_delay = config.move_delay,
            .shoot_delay = config.shoot_delay,
        };
    }
};

pub const Bullet = struct {
    drawable: Drawable,
    speed: f32,
    active: bool,

    pub fn init(config: con.BulletConfig, texture: rl.Texture, x: f32, y: f32, facing: f32) @This() {
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
                .texture = texture,
                .facing = facing,
            },
            .speed = config.speed,
            .active = true,
        };
    }
};
