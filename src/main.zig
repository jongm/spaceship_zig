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
    const background_texture = try rl.loadTexture("assets/backgrounds/Blue Nebula/Blue_Nebula_01-1024x1024.png");
    defer rl.unloadTexture(background_texture);
    const bg_rect_orig = rl.Rectangle{
        .x = 0,
        .y = 0,
        .width = 1024,
        .height = 1024,
    };
    var bg_rects: [val.game_config.bg_rows * val.game_config.bg_cols]rl.Rectangle = undefined;
    for (0..val.game_config.bg_cols) |col| {
        const col_f: f32 = @floatFromInt(col);
        for (0..val.game_config.bg_rows) |row| {
            const row_f: f32 = @floatFromInt(row);
            const bg_rect_dest = rl.Rectangle{
                .x = val.game_config.tile_width * col_f,
                .y = val.game_config.tile_height * row_f,
                .width = val.game_config.tile_width,
                .height = val.game_config.tile_height,
            };
            const n: usize = row * val.game_config.bg_cols + col;
            bg_rects[n] = bg_rect_dest;
        }
    }

    // Skill Wheel
    const sword_wheel_texture = try rl.loadTexture("assets/circle_sword.png");
    defer rl.unloadTexture(sword_wheel_texture);
    const bullet_wheel_texture = try rl.loadTexture("assets/circle_bullet.png");
    defer rl.unloadTexture(bullet_wheel_texture);
    const empty_wheel_texture = try rl.loadTexture("assets/circle_empty.png");
    defer rl.unloadTexture(empty_wheel_texture);
    const x_wheel_texture = try rl.loadTexture("assets/circle_shield.png");
    defer rl.unloadTexture(x_wheel_texture);
    const y_wheel_texture = try rl.loadTexture("assets/circle_y.png");
    defer rl.unloadTexture(y_wheel_texture);
    const r2_wheel_texture = try rl.loadTexture("assets/circle_bulletbomb.png");
    defer rl.unloadTexture(r2_wheel_texture);
    const l1_wheel_texture = try rl.loadTexture("assets/circle_l1.png");
    defer rl.unloadTexture(l1_wheel_texture);
    const l2_wheel_texture = try rl.loadTexture("assets/circle_l2.png");
    defer rl.unloadTexture(l2_wheel_texture);
    val.wheel_config.up_texture = y_wheel_texture;
    val.wheel_config.left_texture = x_wheel_texture;
    val.wheel_config.right_texture = bullet_wheel_texture;
    val.wheel_config.r1_texture = sword_wheel_texture;
    val.wheel_config.r2_texture = r2_wheel_texture;
    val.wheel_config.l1_texture = l1_wheel_texture;
    val.wheel_config.l2_texture = l2_wheel_texture;

    // Entities
    const player_texture = try rl.loadTexture("assets/ship1.png");
    defer rl.unloadTexture(player_texture);
    val.player_config.texture = player_texture;

    const ships_texture = try rl.loadTexture("assets/ships1.png");
    defer rl.unloadTexture(ships_texture);
    val.enemy11_config.texture = ships_texture;
    val.enemy12_config.texture = ships_texture;
    val.enemy13_config.texture = ships_texture;
    val.enemy14_config.texture = ships_texture;
    val.enemy21_config.texture = ships_texture;
    val.enemy22_config.texture = ships_texture;
    val.enemy23_config.texture = ships_texture;
    val.enemy24_config.texture = ships_texture;
    val.enemy31_config.texture = ships_texture;
    val.enemy32_config.texture = ships_texture;
    val.enemy33_config.texture = ships_texture;
    val.enemy34_config.texture = ships_texture;
    val.enemy41_config.texture = ships_texture;
    val.enemy42_config.texture = ships_texture;
    val.enemy43_config.texture = ships_texture;
    val.enemy44_config.texture = ships_texture;

    const bullets_texture = try rl.loadTexture("assets/bullets1.png");
    defer rl.unloadTexture(bullets_texture);
    val.bullet_config.texture = bullets_texture;
    val.bullet_bomb_config.texture = bullets_texture;
    val.bullet_bomb_bullet_config.texture = bullets_texture;

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
    // defer rl.unloadSound(explo1_sound);
    // val.enemy_config.death_sound = explo1_sound;

    const explo2_sound = try rl.loadSound("sfx/destroyed1.wav");
    defer rl.unloadSound(explo2_sound);
    val.player_config.death_sound = explo1_sound;

    const bgm_music = try rl.loadMusicStream("music/bgm1.mp3");
    defer rl.unloadMusicStream(bgm_music);

    // Create objects
    var player: obj.Player = undefined;
    var bullets_arr: [10]obj.Bullet = undefined;
    var bullets: obj.MaxArray(obj.Bullet) = .{ .list = &bullets_arr };
    var bomb_bullets_arr: [20]obj.Bullet = undefined;
    var bomb_bullets: obj.MaxArray(obj.Bullet) = .{ .list = &bomb_bullets_arr };
    var enemies_arr: [50]obj.Enemy = undefined;
    var enemies: obj.MaxArray(obj.Enemy) = .{ .list = &enemies_arr };
    var sword: obj.Sword = undefined;
    var bomb: obj.BulletBomb = undefined;
    var spawn_timer_e1: u32 = 0;
    var spawn_timer_e2: u32 = 0;
    var spawn_timer_e3: u32 = 0;
    var spawn_timer_e4: u32 = 0;
    var player_skills = [_]ski.Skill{
        ski.shoot_skill,
        ski.sword_skill,
        ski.bullet_bomb_skill,
        ski.shield_skill,
    };

    const skill_wheel = men.SkillWheel.init(val.wheel_config);

    const state = con.GameState{
        .player = &player,
        .bullets = &bullets,
        .bomb_bullets = &bomb_bullets,
        .enemies = &enemies,
        .sword = &sword,
        .bomb = &bomb,
        .spawn_timer_e1 = &spawn_timer_e1,
        .spawn_timer_e2 = &spawn_timer_e2,
        .spawn_timer_e3 = &spawn_timer_e3,
        .spawn_timer_e4 = &spawn_timer_e4,
        .game_config = &val.game_config,
        .game_status = &game_status,
    };

    uti.reset_game_status(state, &player_skills);

    rl.playMusicStream(bgm_music);

    // Camera
    var camera = rl.Camera2D{
        .target = .{
            .x = player.drawable.rect_dest.x,
            .y = player.drawable.rect_dest.y,
        },
        .offset = .{
            .x = val.game_config.screen_width / 2.0,
            .y = val.game_config.screen_height / 2.0,
        },
        .rotation = 0.0,
        .zoom = 1.0,
    };

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
                rl.stopMusicStream(bgm_music);
                if (rl.isGamepadButtonPressed(0, rl.GamepadButton.right_face_down)) {
                    uti.reset_game_status(state, &player_skills);
                    player.skills = &player_skills;
                    rl.playMusicStream(bgm_music);
                    game_status = .gameplay;
                }
            },
            .gameplay => {
                if (rl.isGamepadButtonPressed(0, rl.GamepadButton.middle_right)) {
                    game_status = .pause;
                }

                // Timers
                spawn_timer_e1 += 1;
                spawn_timer_e2 += 1;
                spawn_timer_e3 += 1;
                spawn_timer_e4 += 1;
                for (player.skills) |*skill| {
                    skill.timer += 1;
                }

                rl.updateMusicStream(bgm_music);

                // Control logic
                gam.handle_controls(state);

                // Camera
                uti.update_camera(&camera, player.drawable.rect_dest);

                // Spawn enemies
                if (spawn_timer_e1 >= val.game_config.spawn_delay_e1) {
                    spawn_timer_e1 = 0;
                    obj.Enemy.spawn(state, val.enemy11_config);
                }
                if (spawn_timer_e2 >= val.game_config.spawn_delay_e2) {
                    spawn_timer_e2 = 0;
                    obj.Enemy.spawn(state, val.enemy12_config);
                }
                if (spawn_timer_e3 >= val.game_config.spawn_delay_e3) {
                    spawn_timer_e3 = 0;
                    obj.Enemy.spawn(state, val.enemy13_config);
                }
                if (spawn_timer_e4 >= val.game_config.spawn_delay_e4) {
                    spawn_timer_e4 = 0;
                    obj.Enemy.spawn(state, val.enemy14_config);
                }

                // Update skills
                for (0..bullets.max) |i| {
                    bullets.list[i].update(state);
                }
                sword.update(player.drawable, state);
                bomb.update(state);
                for (0..bomb_bullets.max) |i| {
                    bomb_bullets.list[i].update(state);
                }
                // Update enemies
                for (0..enemies.max) |i| {
                    state.enemies.list[i].update(state);
                }

                // Update player
                player.update(state);

                // Draw logic

                rl.beginMode2D(camera);
                for (bg_rects) |rect| {
                    rl.drawTexturePro(
                        background_texture,
                        bg_rect_orig,
                        rect,
                        .{ .x = 0, .y = 0 },
                        0.0,
                        rl.Color.white,
                    );
                }

                player.draw();
                for (0..enemies.max) |i| {
                    enemies.list[i].draw();
                }

                for (0..bullets.max) |i| {
                    bullets.list[i].draw();
                }
                sword.draw();

                bomb.draw();
                for (0..bomb_bullets.max) |i| {
                    bomb_bullets.list[i].draw();
                }

                rl.endMode2D();

                const health_text = rl.textFormat("Health: %d", .{player.health});
                rl.drawText(health_text, 10, 10, 40, rl.Color.green);
                const score_text = rl.textFormat("Score: %d", .{player.score});
                rl.drawText(score_text, 1400, 10, 40, rl.Color.green);

                skill_wheel.draw(state);
            },
            else => {},
        }
    }
}
