package inavders

import "core:fmt"
import "core:math"
import rl "vendor:raylib"


// Constants
WINDOW_WIDTH     :: 480 * 2 
WINDOW_HEIGHT    :: 360 * 2
TILE_WIDTH       :: 16
TILE_HEIGHT      :: 16
TILE_DATA        :: #load("tileset.png")

// Type Alias
Vec2      :: rl.Vector2
Rectangle :: rl.Rectangle

Player :: struct {
    rec: Rectangle,
    pos: Vec2,
    vel: Vec2,
    speed: int,
    is_dead: bool,
}

Invader :: struct {
    rec: rl.Rectangle
}

Game_Memory :: struct {
    player: Player,
    invaders: [dynamic]Invader,
    score: int,
    lives: int,
    tileset: rl.Texture2D
}

gm := Game_Memory{}
invaders: [dynamic]Invader = {}
tileset: rl.Texture2D 

main :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Invaders")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    init_memory()

    for !rl.WindowShouldClose() {

	// Input
	if !gm.player.is_dead {
	    if rl.IsKeyDown(.A) do gm.player.pos.x -= 10
	    if rl.IsKeyDown(.D) do gm.player.pos.x += 10
	}

	// Simulate
	if gm.player.pos.x < 0 {
	    gm.player.pos.x = 2
	}
	if gm.player.pos.x > WINDOW_WIDTH - TILE_WIDTH {
	    gm.player.pos.x = WINDOW_WIDTH - TILE_WIDTH
	}

	// Render
	draw()
    }

}

init_memory :: proc() {

    // Load the tileset
    tileset_image := rl.LoadImageFromMemory(".png", raw_data(TILE_DATA), i32(len(TILE_DATA))) 
    gm.tileset = rl.LoadTextureFromImage(tileset_image)
    rl.UnloadImage(tileset_image)

    //Init the player
    gm.player = Player{ pos = { WINDOW_WIDTH / 2 - 8, WINDOW_HEIGHT * 0.95}}
}

draw_player :: proc() {
    tileset := gm.tileset
    frame_width := tileset.width / 16
    frame_height := tileset.height / 8
    source : rl.Rectangle = {128, 128, f32(frame_width), -f32(frame_height)}
    dest : rl.Rectangle = {gm.player.pos.x, gm.player.pos.y, f32(frame_width) * 2, f32(frame_height) * 2}
    origin := Vec2{f32(frame_width) / 2, f32(frame_height) / 2}
    rotation := 0

    rl.DrawTexturePro(tileset, source, dest, origin, f32(rotation), rl.WHITE )
}

draw_background :: proc() {
    tileset := gm.tileset
    frame_width := tileset.width / 2
    frame_height := tileset.height

    for y := f32(0); y < f32(WINDOW_HEIGHT); y += f32(frame_height) {
	for x:= f32(0); x < f32(WINDOW_WIDTH); x += f32(frame_width){
	    source : rl.Rectangle = {0, 0, f32(frame_width), f32(frame_height)}
	    dest : rl.Rectangle = {f32(x), f32(y), f32(frame_width), f32(frame_height) * 2}
	    origin := Vec2{f32(frame_width) / 2, f32(frame_height) / 2}
	    rotation := 0

	    rl.DrawTexturePro(tileset, source, dest, origin, f32(rotation), rl.WHITE )
	}
    }
}

draw :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    draw_background()
    draw_player()
    
} 

