extends "res://Scripts/PhysicsObject.gd"

signal death

export var force_damage_scaler = 0.01
export var min_damaging_force = 1000

export var penetration_damage = 0.0
export var max_hp = 100.0
export var dps_on_floor = 0.0
var hp

# Called when the node enters the scene tree for the first time.
func _ready():
	hp = max_hp
	$HPBar.max_value = max_hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if altitude <= 0:
		hp -= dps_on_floor * delta
	if hp <= 0:
		emit_signal("death", self)
		queue_free()
	$HPBar.value = hp


func _on_Destructible_hit(other, force):
	hp -= max(0, force - min_damaging_force) * force_damage_scaler
	if hp <= 0:
		emit_signal("death", self)
		queue_free()
