const rl = @import("raylib");
const con = @import("config.zig");
const obj = @import("objects.zig");
const uti = @import("utils.zig");
const gam = @import("gamepad.zig");
const std = @import("std");

const game_config = con.GameConfig{
    .screen_width = 1600,
    .screen_height = 1000,
    .spawn_delay = 50,
    .rotation_speed = 50,
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
    .health = 5,
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

var game_status: con.GameStatus = .gameplay;

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

    const sword_texture = try rl.loadTexture("assets/sword1.png");
    defer rl.unloadTexture(sword_texture);

    // Create configs
    const mybullet = con.BulletConfig{
        .height = 30,
        .width = 20,
        .speed = 20,
        .tex_x = 69,
        .tex_y = 225,
        .tex_w = 10,
        .tex_h = 20,
        .texture = bullets_texture,
    };

    // Create objects
    var player = obj.Player.init(player_config, player_texture);
    var bullets: [10]obj.Bullet = undefined;
    var enemies: [20]obj.Enemy = undefined;
    var swords: [1]obj.Sword = undefined;
    var spawn_timer: u32 = 0;

    var shoot_skill = obj.Skill{
        .cooldown = 20,
        .timer = 0,
    };
    var sword_skill = obj.Skill{
        .cooldown = 200,
        .timer = 0,
    };
    var all_skills = [_]*obj.Skill{ &shoot_skill, &sword_skill };
    player.skills = &all_skills;

    const state = con.GameState{
        .player = &player,
        .bullets = &bullets,
        .enemies = &enemies,
        .swords = &swords,
        .spawn_timer = &spawn_timer,
        .game_config = &game_config,
        .mybullet = mybullet,
    };

    uti.reset_game_status(state);

    // Main loop
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        switch (game_status) {
            .game_lost => {
                rl.clearBackground(rl.Color.black);
                rl.drawText("Game Over", game_config.screen_width / 2, game_config.screen_height / 2 + 200, 40, rl.Color.red);
                rl.drawText("Press A to restart", game_config.screen_width / 2, game_config.screen_height / 2, 30, rl.Color.red);
                if (rl.isGamepadButtonPressed(0, rl.GamepadButton.right_face_down)) {
                    uti.reset_game_status(state);
                    game_status = .gameplay;
                }
            },
            .gameplay => {
                // Timers
                spawn_timer += 1;
                for (player.skills) |skill| {
                    skill.timer += 1;
                }

                // Control logic
                gam.handle_controls(state);

                // Spawn enemies
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

                // Update bullets
                for (&bullets) |*bullet| {
                    bullet.update(state);
                }

                // Update enemies
                for (&enemies) |*enemy| {
                    enemy.update(state);
                }

                // Update player
                if (player.health <= 0) {
                    game_status = .game_lost;
                }

                // Draw logic
                rl.drawTexture(background_texture, 0, 0, rl.Color.white);
                const health_text = rl.textFormat("Health: %d", .{player.health});
                rl.drawText(health_text, 10, 10, 40, rl.Color.green);
                const score_text = rl.textFormat("Score: %d", .{player.score});
                rl.drawText(score_text, 1400, 10, 40, rl.Color.green);

                uti.draw_object(player.drawable);

                for (enemies) |enemy| {
                    enemy.draw();
                }

                for (bullets) |bullet| {
                    bullet.draw();
                }
            },
            else => {},
        }
    }
}
