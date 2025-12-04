const rl = @import("raylib");
const con = @import("config.zig");
const obj = @import("objects.zig");
const uti = @import("utils.zig");

const game_config = con.GameConfig{
    .screen_width = 1600,
    .screen_height = 1000,
};

const player_config = con.PlayerConfig{
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 392,
    .tex_h = 338,
    .start_x = 820,
    .start_y = 520,
    .width = 40,
    .height = 40,
    .speed = 10,
    .rotation_speed = 5,
};

const mybullet = con.BulletConfig{
    .height = 20,
    .width = 10,
    .speed = 20,
    .tex_x = 69,
    .tex_y = 225,
    .tex_w = 10,
    .tex_h = 20,
};

pub fn main() !void {
    rl.initWindow(
        game_config.screen_width,
        game_config.screen_height,
        "Zig Spaceship",
    );
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    // Load Assets
    var background_texture = try rl.loadTexture("assets/spacebg1.png");
    defer rl.unloadTexture(background_texture);
    background_texture.width = game_config.screen_width;
    background_texture.height = game_config.screen_height;

    const player_texture = try rl.loadTexture("assets/ship1.png");
    defer rl.unloadTexture(player_texture);
    // player_texture.width = player_config.width;
    // player_texture.height = player_config.height;

    const bullets_texture = try rl.loadTexture("assets/bullets1.png");
    defer rl.unloadTexture(bullets_texture);

    // Create objects
    var player = obj.Player.init(player_config, player_texture);

    var bullets: [10]obj.Bullet = undefined;
    for (&bullets, 0..) |_, i| {
        bullets[i] = .{ .drawable = undefined, .speed = undefined, .active = false };
    }

    // Main loop
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        // Control logic
        if (rl.isKeyDown(rl.KeyboardKey.up)) {
            player.drawable.rect_dest.y -= player.speed;
            uti.update_facing(&player.drawable, player.rotation_speed, 0);
        }
        if (rl.isKeyDown(rl.KeyboardKey.down)) {
            player.drawable.rect_dest.y += player.speed;
            uti.update_facing(&player.drawable, player.rotation_speed, 180);
        }
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            player.drawable.rect_dest.x -= player.speed;
            uti.update_facing(&player.drawable, player.rotation_speed, 270);
        }
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            player.drawable.rect_dest.x += player.speed;
            uti.update_facing(&player.drawable, player.rotation_speed, 90);
        }

        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (&bullets, 0..) |*bullet, i| {
                if (!bullet.active) {
                    const new_bullet = obj.Bullet.init(
                        mybullet,
                        bullets_texture,
                        player.drawable.rect_dest.x + player.drawable.rect_dest.width / 2,
                        player.drawable.rect_dest.y + player.drawable.rect_dest.height / 2,
                        player.drawable.facing,
                    );
                    bullets[i] = new_bullet;
                    break;
                }
            }
        }

        // Update logic
        for (&bullets) |*bullet| {
            if (bullet.active) {
                const moves = uti.get_angle_movement(bullet.speed, bullet.drawable.facing);
                bullet.drawable.rect_dest.x += moves.x;
                bullet.drawable.rect_dest.y += moves.y;
                if (bullet.drawable.rect_dest.x <= 0 or bullet.drawable.rect_dest.x >= game_config.screen_width or bullet.drawable.rect_dest.y <= 0 or bullet.drawable.rect_dest.y >= game_config.screen_height) {
                    bullet.active = false;
                }
            }
        }
        // Draw logic
        rl.drawTexture(background_texture, 0, 0, rl.Color.white);
        // rl.drawRectangleRec(player.drawable.rect_dest, rl.Color.white);

        uti.draw_object(player.drawable);

        for (bullets) |bullet| {
            uti.draw_object(bullet.drawable);
        }
    }
}
