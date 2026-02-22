package main
import rl "vendor:raylib"

player_score: int = 0
cpu_score: int = 0

Green := rl.Color{38, 185, 154, 255}
Dark_Green := rl.Color{20, 160, 133, 255}
Light_Green := rl.Color{129, 204, 184, 255}
Yellow := rl.Color{243, 213, 91, 255}


Ball :: struct {
	x, y:             i32,
	speed_x, speed_y: i32,
	radius:           i32,
}

Paddle :: struct {
	x, y:          f32,
	width, height: f32,
	speed:         i32,
}

CpuPaddle :: struct {
	using paddle: Paddle,
}


ball_draw :: proc(b: Ball) {
	rl.DrawCircle(i32(b.x), i32(b.y), f32(b.radius), Yellow)
}

ball_reset :: proc(b: ^Ball) {
	b.x = rl.GetScreenWidth() / 2
	b.y = rl.GetScreenHeight() / 2

	speed_choices := [2]i32{-1, 1}
	b.speed_x *= speed_choices[rl.GetRandomValue(0, 1)]
	b.speed_y *= speed_choices[rl.GetRandomValue(0, 1)]

}


ball_update :: proc(b: ^Ball) {
	b.x += b.speed_x
	b.y += b.speed_y

	if b.y + b.radius >= rl.GetScreenHeight() || b.y - b.radius <= 0 {
		b.speed_y *= -1
	}

	if b.x + b.radius >= rl.GetScreenWidth() {
		cpu_score += 1
		ball_reset(b)
	}

	if b.x - b.radius <= 0 {
		player_score += 1
		ball_reset(b)
	}

}


paddle_draw :: proc(p: Paddle) {
	rl.DrawRectangleRounded(rl.Rectangle{p.x, p.y, p.width, p.height}, 0.8, 0, rl.WHITE)
}


paddle_limit_movement :: proc(p: ^Paddle) {
	if p.y <= 0 {
		p.y = 0
	}

	if i32(p.y + p.height) >= rl.GetScreenHeight() {
		p.y = f32(rl.GetScreenHeight() - i32(p.height))
	}
}

paddle_update :: proc(p: ^Paddle) {
	if rl.IsKeyDown(rl.KeyboardKey.UP) {
		p.y = p.y - f32(p.speed)
	}

	if rl.IsKeyDown(rl.KeyboardKey.DOWN) {
		p.y = p.y + f32(p.speed)
	}

	paddle_limit_movement(p)

}

cpu_paddle_update :: proc(cpu: ^CpuPaddle, ball_y: i32) {
	if cpu.y + cpu.height / 2 > f32(ball_y) {
		cpu.y = f32(cpu.y - f32(cpu.speed))
	}

	if cpu.y + cpu.height / 2 <= f32(ball_y) {
		cpu.y = f32(cpu.y + f32(cpu.speed))
	}

	paddle_limit_movement(cpu)
}

main :: proc() {
	screen_width: i32 = 1280
	screen_height: i32 = 800

	rl.InitWindow(screen_width, screen_height, "Pong Game")
	rl.SetTargetFPS(60)

	ball := Ball {
		x       = screen_width / 2,
		y       = screen_height / 2,
		speed_x = 7,
		speed_y = 7,
		radius  = 20,
	}

	p_width :: 25
	p_height :: 120

	player := Paddle {
		width  = p_width,
		height = p_height,
		x      = f32(screen_width) - p_width - 10,
		y      = f32(screen_height) / 2 - p_height / 2,
		speed  = 6,
	}

	cpu_height :: 120
	cpu_width :: 25
	cpu := CpuPaddle {
		height = cpu_height,
		width  = cpu_width,
		x      = 10,
		y      = f32(screen_height / 2 - cpu_height / 2),
		speed  = 6,
	}


	for !rl.WindowShouldClose() {
		rl.BeginDrawing()

		ball_update(&ball)
		paddle_update(&player)
		cpu_paddle_update(&cpu, ball.y)

		if rl.CheckCollisionCircleRec(
			rl.Vector2{f32(ball.x), f32(ball.y)},
			f32(ball.radius),
			rl.Rectangle{player.x, player.y, player.width, player.height},
		) {
			ball.speed_x *= -1
		}

		if rl.CheckCollisionCircleRec(
			rl.Vector2{f32(ball.x), f32(ball.y)},
			f32(ball.radius),
			rl.Rectangle{cpu.x, cpu.y, cpu.width, cpu.height},
		) {
			ball.speed_x *= -1
		}

		rl.ClearBackground(Dark_Green)
		rl.DrawRectangle(screen_width / 2, 0, screen_height, screen_height, Green)
		rl.DrawCircle(screen_width / 2, screen_height / 2, 150, Light_Green)

		rl.DrawLine(screen_width / 2, 0, screen_width / 2, screen_height, rl.WHITE)

		ball_draw(ball)
		paddle_draw(cpu)
		paddle_draw(player)

		rl.DrawText(rl.TextFormat("%i", cpu_score), screen_width / 4 - 20, 20, 80, rl.WHITE)
		rl.DrawText(rl.TextFormat("%i", player_score), 3 * screen_width / 4 - 20, 20, 80, rl.WHITE)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
