extends "res://Scripts/PhysicsObject.gd"
class_name Destructible

export var force_damage_scaler = 0.0005
export var min_damaging_force = 1000

export var penetration_damage = 0.0
export var max_hp = 100.0
export var dps_on_floor = 0.0
var hp

# Wysyłany po zniszczeniu obiektu przez wyczerpanie hp, argumenty - self
signal death

# Called when the node enters the scene tree for the first time.
func _ready():
	hp = max_hp
	$HPBar.max_value = max_hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if altitude <= 0: # despawn np. pocisków na ziemi
		hp -= dps_on_floor * delta
	if hp <= 0:
		die()
	$HPBar.value = hp


func _on_Destructible_hit(_other, force):
	hp -= max(0, force - min_damaging_force) * force_damage_scaler
	if hp <= 0:
		die()

func die():
	emit_signal("death", self)
	queue_free()
