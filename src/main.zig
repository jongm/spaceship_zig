const rl = @import("raylib");
const con = @import("config.zig");
const obj = @import("objects.zig");
const uti = @import("utils.zig");
const std = @import("std");

const game_config = con.GameConfig{
    .screen_width = 1600,
    .screen_height = 1000,
    .spawn_delay = 150,
};

const player_config = con.PlayerConfig{
    .tex_x = 0,
    .tex_y = 0,
    .tex_w = 392,
    .tex_h = 338,
    .start_x = 820,
    .start_y = 520,
    .width = 60,
    .height = 60,
    .speed = 10,
    .rotation_speed = 20,
};

const enemy_config = con.EnemyConfig{
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

    const enemy_texture = try rl.loadTexture("assets/alien1.png");
    defer rl.unloadTexture(enemy_texture);

    const bullets_texture = try rl.loadTexture("assets/bullets1.png");
    defer rl.unloadTexture(bullets_texture);

    // Create objects
    var player = obj.Player.init(player_config, player_texture);

    var bullets: [10]obj.Bullet = undefined;
    for (&bullets, 0..) |_, i| {
        bullets[i] = .{ .drawable = undefined, .speed = undefined, .active = false };
    }

    var enemies: [20]obj.Enemy = undefined;
    for (&enemies, 0..) |_, i| {
        enemies[i] = .{
            .drawable = undefined,
            .speed = undefined,
            .rotation_speed = undefined,
            .move_delay = undefined,
            .shoot_delay = undefined,
            .alive = false,
        };
    }

    var spawn_timer: u32 = 0;

    // Main loop
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        // Control logic
        const leftx = rl.getGamepadAxisMovement(0, rl.GamepadAxis.left_x);
        const lefty = rl.getGamepadAxisMovement(0, rl.GamepadAxis.left_y);
        if (@abs(leftx) > 0.15 or @abs(lefty) > 0.15) {
            const player_angle = uti.angle_from_gamepad(leftx, lefty);
            const player_speed = player.speed * @min(1.0, @abs(leftx) + @abs(lefty));
            const player_move = uti.get_angle_movement(player_speed, player_angle);
            player.drawable.rect_dest.x += player_move.x;
            player.drawable.rect_dest.y += player_move.y;
        }

        const rightx = rl.getGamepadAxisMovement(0, rl.GamepadAxis.right_x);
        const righty = rl.getGamepadAxisMovement(0, rl.GamepadAxis.right_y);
        if (@abs(rightx) > 0.15 or @abs(righty) > 0.15) {
            const turn_target = uti.angle_from_gamepad(rightx, righty) + 90;
            uti.update_facing(&player.drawable, player.rotation_speed, turn_target);
        }
        // if (rl.isKeyPressed(rl.KeyboardKey.space)) {
        if (rl.isGamepadButtonPressed(0, rl.GamepadButton.right_trigger_2)) {
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

        // if (rl.isKeyDown(rl.KeyboardKey.up)) {
        //     player.drawable.rect_dest.y -= player.speed;
        //     uti.update_facing(&player.drawable, player.rotation_speed, 0);
        // }
        // if (rl.isKeyDown(rl.KeyboardKey.down)) {
        //     player.drawable.rect_dest.y += player.speed;
        //     uti.update_facing(&player.drawable, player.rotation_speed, 180);
        // }
        // if (rl.isKeyDown(rl.KeyboardKey.left)) {
        //     player.drawable.rect_dest.x -= player.speed;
        //     uti.update_facing(&player.drawable, player.rotation_speed, 270);
        // }
        // if (rl.isKeyDown(rl.KeyboardKey.right)) {
        //     player.drawable.rect_dest.x += player.speed;
        //     uti.update_facing(&player.drawable, player.rotation_speed, 90);
        // }

        // Update bullets
        for (&bullets) |*bullet| {
            if (bullet.active) {
                const moves = uti.get_angle_movement(bullet.speed, bullet.drawable.facing - 90);
                bullet.drawable.rect_dest.x += moves.x;
                bullet.drawable.rect_dest.y += moves.y;
                if (bullet.drawable.rect_dest.x <= 0 or bullet.drawable.rect_dest.x >= game_config.screen_width or bullet.drawable.rect_dest.y <= 0 or bullet.drawable.rect_dest.y >= game_config.screen_height) {
                    bullet.active = false;
                }
                for (&enemies) |*enemy| {
                    if (enemy.alive) {
                        if (rl.checkCollisionRecs(enemy.drawable.rect_dest, bullet.drawable.rect_dest)) {
                            enemy.alive = false;
                            bullet.active = false;
                        }
                    }
                }
            }
        }

        // Spawn enemies
        spawn_timer += 1;
        if (spawn_timer >= game_config.spawn_delay) {
            spawn_timer = 0;
            for (enemies, 0..) |enemy, i| {
                if (!enemy.alive) {
                    const position = uti.get_random_border_position(game_config.screen_width, game_config.screen_height);
                    var new_enemy = obj.Enemy.init(
                        enemy_config,
                        enemy_texture,
                        0.0,
                        position.x,
                        position.y,
                    );
                    new_enemy.alive = true;
                    enemies[i] = new_enemy;
                    break;
                }
            }
        }

        // Update enemies
        for (&enemies) |*enemy| {
            if (enemy.alive) {
                uti.move_towards(&enemy.drawable, &player.drawable, enemy.speed);
            }
        }

        // Draw logic
        rl.drawTexture(background_texture, 0, 0, rl.Color.white);

        uti.draw_object(player.drawable);

        for (enemies) |enemy| {
            if (enemy.alive) {
                uti.draw_object(enemy.drawable);
            }
        }

        for (bullets) |bullet| {
            if (bullet.active) {
                std.debug.print("Player facing: {d}, Bullet facing: {d}\n", .{ player.drawable.facing, bullet.drawable.facing });
                uti.draw_object(bullet.drawable);
            }
        }
    }
}
