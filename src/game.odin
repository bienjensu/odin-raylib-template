package game

import "core:fmt"
import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

WINDOW_WIDTH :: 640
WINDOW_HEIGHT :: 480

GAME_WIDTH :: 640.
GAME_HEIGHT :: 480.

target: rl.RenderTexture

Game_Memory :: struct {
	player_pos:     rl.Vector2,
	player_texture: rl.Texture,
	some_number:    int,
}

g_mem: ^Game_Memory

game_camera :: proc() -> rl.Camera2D {
	return {
		zoom = 1.0,
		target = g_mem.player_pos,
		offset = {GAME_WIDTH / 2, GAME_HEIGHT / 2},
	}
}

ui_camera :: proc() -> rl.Camera2D {
	return {zoom = 3.0}
}

update :: proc() {
	input: rl.Vector2

	if rl.IsKeyDown(.UP) || rl.IsKeyDown(.W) {
		input.y -= 1
	}
	if rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.S) {
		input.y += 1
	}
	if rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A) {
		input.x -= 1
	}
	if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D) {
		input.x += 1
	}

	input = linalg.normalize0(input)
	g_mem.player_pos += input * rl.GetFrameTime() * 100
	g_mem.some_number += 1
}

draw :: proc() {
	rl.BeginTextureMode(target)
	rl.BeginMode2D(game_camera())
	rl.ClearBackground(rl.DARKGRAY)
	rl.DrawTextureEx(g_mem.player_texture, g_mem.player_pos, 0, 1, rl.WHITE)
	rl.DrawRectangleV({20, 20}, {10, 10}, rl.RED)
	rl.DrawRectangleV({-30, -20}, {10, 10}, rl.GREEN)
	rl.EndMode2D()
	rl.EndTextureMode()

	scale := math.min(
		f32(rl.GetScreenWidth()) / f32(target.texture.width),
		f32(rl.GetScreenHeight()) / f32(target.texture.height),
	)

	rect: rl.Rectangle = {
		(f32(rl.GetScreenWidth()) - f32(target.texture.width) * scale) / 2,
		(f32(rl.GetScreenHeight()) - f32(target.texture.height) * scale) / 2,
		f32(target.texture.width) * scale,
		f32(target.texture.height) * scale,
	}

	rl.BeginDrawing()
	{
		rl.ClearBackground(rl.BLACK)
		rl.DrawTexturePro(
			target.texture,
			{0, 0, f32(target.texture.width), f32(-target.texture.height)},
			rect,
			{0, 0},
			0,
			rl.WHITE,
		)
	}


	// NOTE: `fmt.ctprintf` uses the temp allocator. The temp allocator is
	// cleared at the end of the frame by the main application, meaning inside
	// `main_hot_reload.odin`, `main_release.odin` or `main_web_entry.odin`.
	rl.DrawText(
		fmt.ctprintf(
			"some_number: %v\nplayer_pos: %v",
			g_mem.some_number,
			g_mem.player_pos,
		),
		5,
		5,
		8,
		rl.WHITE,
	)

	rl.EndDrawing()
}

@(export)
game_update :: proc() -> bool {
	handle_fullscreen()
	update()
	draw()
	return !rl.WindowShouldClose()
}

@(export)
game_init_window :: proc() {
	rl.SetConfigFlags({.WINDOW_TOPMOST, .WINDOW_RESIZABLE})
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Template")
	rl.SetTargetFPS(300)

	target = rl.LoadRenderTexture(i32(GAME_WIDTH), i32(GAME_HEIGHT))
	rl.SetTextureFilter(target.texture, .POINT)
}

@(export)
game_init :: proc() {
	g_mem = new(Game_Memory)

	g_mem^ = Game_Memory {
		some_number    = 100,

		// You can put textures, sounds and music in the `assets` folder. Those
		// files will be part any release or web build.
		player_texture = rl.LoadTexture("assets/round_cat.png"),
	}

	game_hot_reloaded(g_mem)
}

@(export)
game_shutdown :: proc() {
	free(g_mem)
}

@(export)
game_shutdown_window :: proc() {
	rl.CloseWindow()
}

@(export)
game_memory :: proc() -> rawptr {
	return g_mem
}

@(export)
game_memory_size :: proc() -> int {
	return size_of(Game_Memory)
}

@(export)
game_hot_reloaded :: proc(mem: rawptr) {
	g_mem = (^Game_Memory)(mem)

	// Here you can also set your own global variables. A good idea is to make
	// your global variables into pointers that point to something inside
	// `g_mem`.
}

@(export)
game_force_reload :: proc() -> bool {
	return rl.IsKeyPressed(.F5)
}

@(export)
game_force_restart :: proc() -> bool {
	return rl.IsKeyPressed(.F6)
}

// In a web build, this is called when browser changes size. Remove the
// `rl.SetWindowSize` call if you don't want a resizable game.
game_parent_window_size_changed :: proc(w, h: int) {
	rl.SetWindowSize(i32(w), i32(h))
}

handle_fullscreen :: proc() {
	if (rl.IsKeyDown(.LEFT_ALT) || rl.IsKeyDown(.RIGHT_ALT)) &&
	   rl.IsKeyPressed(.ENTER) {
		// fmt.println("Toggling fullscreen.")
		if rl.IsWindowFullscreen() {
			rl.ToggleBorderlessWindowed()
			rl.SetWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT)
		} else {
			rl.SetWindowSize(
				rl.GetMonitorWidth(rl.GetCurrentMonitor()),
				rl.GetMonitorHeight(rl.GetCurrentMonitor()),
			)
			rl.ToggleBorderlessWindowed()
		}
	}
}
