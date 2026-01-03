const rl = @import("raylib");
const con = @import("config.zig");
const obj = @import("objects.zig");
const uti = @import("utils.zig");
const gam = @import("gamepad.zig");
const val = @import("values.zig");
const men = @import("menu.zig");
const ski = @import("skills.zig");
const std = @import("std");

var game_status: con.GameStatus = .gameplay;

pub fn main() !void {
    rl.initWindow(
        val.game_config.screen_width,
        val.game_config.screen_height,
        "Zig Spaceship",
    );
    defer rl.closeWindow();

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    rl.setTargetFPS(60);

    // Load Assets
    var background_texture = try rl.loadTexture("assets/spacebg1.png");
    defer rl.unloadTexture(background_texture);
    background_texture.width = val.game_config.screen_width;
    background_texture.height = val.game_config.screen_height;

    const sword_wheel_texture = try rl.loadTexture("assets/circle_sword.png");
    defer rl.unloadTexture(sword_wheel_texture);
    const empty_wheel_texture = try rl.loadTexture("assets/circle_empty.png");
    defer rl.unloadTexture(empty_wheel_texture);
    val.wheel_config.up_texture = empty_wheel_texture;
    val.wheel_config.left_texture = empty_wheel_texture;
    val.wheel_config.right_texture = empty_wheel_texture;
    val.wheel_config.down_texture = sword_wheel_texture;

    const player_texture = try rl.loadTexture("assets/ship1.png");
    defer rl.unloadTexture(player_texture);
    val.player_config.texture = player_texture;

    const enemy_texture = try rl.loadTexture("assets/alien1.png");
    defer rl.unloadTexture(enemy_texture);
    val.enemy_config.texture = enemy_texture;

    const bullets_texture = try rl.loadTexture("assets/bullets1.png");
    defer rl.unloadTexture(bullets_texture);
    val.bullet_config.texture = bullets_texture;

    const sword_texture = try rl.loadTexture("assets/sword1.png");
    defer rl.unloadTexture(sword_texture);
    val.sword_config.texture = sword_texture;

    // Load sounds
    const bullet_sound = try rl.loadSound("sfx/laser1.wav");
    rl.setSoundVolume(bullet_sound, 0.2);
    rl.setSoundPitch(bullet_sound, 0.5);
    defer rl.unloadSound(bullet_sound);
    val.bullet_config.sound = bullet_sound;

    const sword_sound = try rl.loadSound("sfx/sword1.wav");
    defer rl.unloadSound(sword_sound);
    val.sword_config.sound = sword_sound;

    const explo1_sound = try rl.loadSound("sfx/explosion_short1.wav");
    rl.setSoundVolume(explo1_sound, 0.3);
    defer rl.unloadSound(explo1_sound);
    val.enemy_config.death_sound = explo1_sound;

    const explo2_sound = try rl.loadSound("sfx/destroyed1.wav");
    defer rl.unloadSound(explo2_sound);
    val.player_config.death_sound = explo1_sound;

    const bgm_music = try rl.loadMusicStream("music/bgm1.mp3");
    defer rl.unloadMusicStream(bgm_music);

    // Create objects
    var player = obj.Player.init(val.player_config);
    var bullets: [10]obj.Bullet = undefined;
    var enemies: [20]obj.Enemy = undefined;
    var sword: obj.Sword = undefined;
    var spawn_timer: u32 = 0;

    const skill_wheel = men.SkillWheel.init(val.wheel_config);

    var shoot_skill = ski.BulletSkill{
        .cooldown = 20,
        .timer = 20,
        .icon = undefined,
    };
    var sword_skill = ski.SwordSkill{
        .cooldown = 100,
        .timer = 100,
        .icon = undefined,
    };
    player.skill1 = &shoot_skill;
    player.skill2 = &sword_skill;

    const state = con.GameState{
        .player = &player,
        .bullets = &bullets,
        .enemies = &enemies,
        .sword = &sword,
        .spawn_timer = &spawn_timer,
        .game_config = &val.game_config,
        .game_status = &game_status,
    };

    uti.reset_game_status(state);

    rl.playMusicStream(bgm_music);

    // Main loop
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        switch (game_status) {
            .pause => {
                rl.clearBackground(rl.colorAlpha(rl.Color.black, 0.2));
                rl.drawText("Paused", val.game_config.screen_width / 2, val.game_config.screen_height / 2 + 200, 40, rl.Color.white);
                if (rl.isGamepadButtonPressed(0, rl.GamepadButton.middle_right)) {
                    game_status = .gameplay;
                }
            },
            .game_lost => {
                rl.clearBackground(rl.colorAlpha(rl.Color.black, 0.6));
                const score_text = rl.textFormat("Game Over - Score: %d", .{player.score});
                rl.drawText(score_text, val.game_config.screen_width / 2, val.game_config.screen_height / 2 + 200, 40, rl.Color.red);
                rl.drawText("Press A to restart", val.game_config.screen_width / 2, val.game_config.screen_height / 2, 30, rl.Color.red);
                if (rl.isGamepadButtonPressed(0, rl.GamepadButton.right_face_down)) {
                    uti.reset_game_status(state);
                    game_status = .gameplay;
                }
            },
            .gameplay => {
                if (rl.isGamepadButtonPressed(0, rl.GamepadButton.middle_right)) {
                    game_status = .pause;
                }
                // Timers
                spawn_timer += 1;
                player.skill1.timer += 1;
                player.skill2.timer += 1;

                rl.updateMusicStream(bgm_music);

                // Control logic
                gam.handle_controls(state);

                // Spawn enemies
                if (spawn_timer >= val.game_config.spawn_delay) {
                    spawn_timer = 0;
                    for (enemies, 0..) |enemy, i| {
                        if (!enemy.alive) {
                            const position = uti.get_random_border_position(val.game_config.screen_width, val.game_config.screen_height);
                            var new_enemy = obj.Enemy.init(
                                val.enemy_config,
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

                // Update skills
                for (&bullets) |*bullet| {
                    bullet.update(state);
                }
                sword.update(player.drawable, state);

                // Update enemies
                for (&enemies) |*enemy| {
                    enemy.update(state);
                }

                // Update player
                player.update(state);

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
                sword.draw();

                skill_wheel.draw(state);
            },
            else => {},
        }
    }
}
