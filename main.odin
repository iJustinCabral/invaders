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
    rec: rl.Rectangle,
    pos: Vec2,
    vel: Vec2,
    is_dead: bool,
}

Projectile :: struct {
    pos: Vec2,
    vel: Vec2,
    rec: Rectangle,
    ttl: f64,
    spawn_t: f64,
    did_remove: bool
}

Game_Memory :: struct {
    player: Player,
    invaders: [dynamic]Invader,
    score: int,
    lives: int,
    tileset: rl.Texture2D,
    projectiles: [dynamic]Projectile
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
	    if rl.IsKeyPressed(.SPACE) {
		projectile := Projectile {
		    pos = gm.player.pos,
		    vel = {0, 200},
		    ttl = 5,
		    spawn_t = rl.GetTime(),
		    did_remove = false
		}

		append(&gm.projectiles, projectile)
	    }
	}

	// Simulate
	if gm.player.pos.x < 0 {
	    gm.player.pos.x = 6
	}
	if gm.player.pos.x > WINDOW_WIDTH - TILE_WIDTH {
	    gm.player.pos.x = WINDOW_WIDTH - TILE_WIDTH - 6
	}

	update_projectiles(&gm)
	update_invaders()

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
    gm.player = Player{
	pos = { WINDOW_WIDTH / 2 - 8, WINDOW_HEIGHT * 0.95},
	rec = { 0, 0, 32, 32}
    }
    gm.lives = 3
    gm.score = 0

    // Init invaders
    invader_spacing_x := 50
    invader_spacing_y := 50
    rows := 5
    cols := 10

    for y in 0..<rows {
	for x in 0..<cols {
	    position := Vec2{
		f32(x * invader_spacing_x + 100),
		f32(y * invader_spacing_y + 50),
	    }
	    append(&gm.invaders, Invader {
		pos = position,
		is_dead = false,
		rec = {position.x, position.y, 32, 32} // check this after
	    })
	}
    }
}

update_invaders :: proc() {
    move_direction: f32 = 1 // right = 1, left = -1
    steps := 0
    max_steps := 10

    for &invader in gm.invaders {
	if !invader.is_dead {
	    invader.pos.x += move_direction * 2
	    
	    if invader.pos.x > WINDOW_WIDTH - 16 || invader.pos.x < 0 {
		move_direction *= -1
		steps += 1
	    }
	}
    }
}

update_projectiles :: proc(gm: ^Game_Memory) {
    to_remove := make([dynamic]int, context.temp_allocator)
    current_time := rl.GetTime()

    for i in 0..<len(gm.projectiles) {
	p := &gm.projectiles[i]
	old_pos := p.pos
	p.pos -= p.vel * rl.GetFrameTime()

	// Remove projectile after a set amount of time
	if current_time - p.spawn_t >= p.ttl {
	    append(&to_remove, i)
	}

	// Check collision here 
	for &invader, idx in gm.invaders { 
	    if !p.did_remove && rl.CheckCollisionRecs(p.rec, invader.rec){
		p.did_remove = true
		invader.is_dead = true
		remove(&gm.invaders, invader)
		break
	    }
	}
    }

    for i in 0..<len(to_remove) {
	ordered_remove(&gm.projectiles, to_remove[len(to_remove) - i - 1])
    }
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

draw_invaders :: proc() {
    tileset := gm.tileset
    frame_width := tileset.width / 16
    frame_height := tileset.height / 8
    source := rl.Rectangle{176,224, f32(frame_width), f32(frame_height)}

    // This will eventually be a loop over all !is_dead invaders
    for &invader in gm.invaders {
	dest : rl.Rectangle = {invader.pos.x, invader.pos.y, f32(frame_width) * 2, f32(frame_height) * 2}
	origin := Vec2{f32(frame_width) / 2, f32(frame_height) / 2}
	rotation := 0

	rl.DrawTexturePro(tileset, source, dest, origin, f32(rotation), rl.WHITE )
    }
}

draw_bullet :: proc() {
    tileset := gm.tileset
    frame_width := tileset.width / 16
    frame_height := tileset.height / 8
    source := rl.Rectangle{176, 144, f32(frame_width), -f32(frame_height)}
    for p in gm.projectiles {
	dest := Rectangle{p.pos.x, p.pos.y, f32(frame_width), f32(frame_height)}
	rl.DrawTexturePro(tileset, source, dest, {0,0}, 0, rl.WHITE)
    }
}

draw_score :: proc() {
    tileset := gm.tileset
    frame_width := 32 
    frame_height := 16
    source : rl.Rectangle = {128, 112, f32(frame_width), f32(frame_height)}
    dest : rl.Rectangle = {WINDOW_WIDTH * 0.05, 10, f32(frame_width) * 2, f32(frame_height) * 2}
    origin := Vec2{f32(frame_width) / 2, f32(frame_height) / 2}
    rotation := 0

    rl.DrawTexturePro(tileset, source, dest, origin, f32(rotation), rl.WHITE )

    score_text := fmt.ctprintf("%02d", gm.score)
    score_t_width := rl.MeasureText(score_text, 20)
    rl.DrawText(score_text, WINDOW_WIDTH * 0.15, 15, 20, rl.WHITE)
}

draw_lives :: proc() {
    tileset := gm.tileset
    frame_width := 32 
    frame_height := 16
    source : rl.Rectangle = {224, 112, f32(frame_width), f32(frame_height)}
    dest : rl.Rectangle = {WINDOW_WIDTH * 0.8, 10, f32(frame_width) * 2, f32(frame_height) * 2}
    origin := Vec2{f32(frame_width) / 2, f32(frame_height) / 2}
    rotation := 0

    rl.DrawTexturePro(tileset, source, dest, origin, f32(rotation), rl.WHITE )
    
    
    for x := f32(0); x < f32(gm.lives); x += 1 {
	frame_width := tileset.width / 16
	frame_height := tileset.height / 8
	source : rl.Rectangle = {128, 128, f32(frame_width), -f32(frame_height)}
	dest : rl.Rectangle = {WINDOW_WIDTH * 0.85 + 10 + (x * f32(frame_width + 16)), 12, f32(frame_width) * 2, f32(frame_height) * 2}
	origin := Vec2{f32(frame_width) / 2, f32(frame_height) / 2}
	rotation := 0

	rl.DrawTexturePro(tileset, source, dest, origin, f32(rotation), rl.WHITE )
    }
}

draw :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    draw_background()
    draw_player()
    draw_invaders()
    draw_score()
    draw_lives()
    draw_bullet()
} 

