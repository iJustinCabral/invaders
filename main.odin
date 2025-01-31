package inavders

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

// Constants
WINDOW_WIDTH     :: 480 * 2 
WINDOW_HEIGHT    :: 360 * 2

// Type Alias
Vec2 :: rl.Vector2 

Entity :: struct {
    pos: Vec2,
    vel: Vec2,
}

Player :: struct {
    using entity: Entity
}

Invader :: struct {
    using entity: Entity
}

Game_Memory :: struct {
    player: Player,
    invaders: [dynamic]Invader
}

gm := Game_Memory{}
invaders: [dynamic]Invader = {}

main :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Invaders")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    tileset: rl.Texture2D = rl.LoadTexture("tileset.png")

    frameWidth := tileset.width / 16
    frameHeight := tileset.height / 8
    sourceRec : rl.Rectangle = {128, 128, f32(frameWidth), f32(frameHeight)}
    destRec : rl.Rectangle = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, f32(frameWidth) * 2, f32(frameHeight) * 2}
    origin := Vec2{f32(frameWidth), f32(frameHeight)}
    rotation := 180

    for !rl.WindowShouldClose() {
	// Input

	// Simulate

	// Render
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.DrawTexturePro(tileset, sourceRec, destRec, origin, f32(rotation), rl.WHITE )

	rl.ClearBackground(rl.BLACK)
    }

    defer rl.UnloadTexture(tileset)

}
