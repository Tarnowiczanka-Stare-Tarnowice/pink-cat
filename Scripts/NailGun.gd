extends "res://Scripts/PhysicsObject.gd"

export var bullets_per_second = 10
export var continuous_fire = false

var next_bullet_time = Time.get_ticks_msec()
var prev_shot_id = -1

# Wywoływana gdy jest ciągle naciśnięty przycisk strzału
# shot_id zwiększa się za każdym kliknięciem
func shoot(shot_id):
	var ready = next_bullet_time <= Time.get_ticks_msec()
	if ready and (continuous_fire or shot_id != prev_shot_id):
		$ProjectileSpawner.spawn()
		prev_shot_id = shot_id
		next_bullet_time = Time.get_ticks_msec() + (1000 / bullets_per_second)
