extends "res://Scripts/PhysicsObject.gd"

export var bullets_per_second = 10
export var continuous_fire = false

var next_bullet_time = Time.get_ticks_msec()
var prev_shot_id = -1

func shoot(shot_id):
	var ready = next_bullet_time <= Time.get_ticks_msec()
	if ready and (continuous_fire or shot_id != prev_shot_id):
		$ProjectileSpawner.spawn()
		next_bullet_time = Time.get_ticks_msec() + (1000 / bullets_per_second)
