extends Node2D

export(PackedScene) var projectile;# = preload("res://Scenes/Brick.tscn")
export var velocity_const = 0
export var velocity_scaling_with_distance = 2.0
export var altitude = 100
export var accuracy_degrees = 0.0

signal spawned

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func spawn():
	var inst = projectile.instance()
	
	var d = get_global_mouse_position()-global_position
	d = d.rotated(deg2rad((randf()-0.5) * 2*accuracy_degrees))
	
	var v = Vector3(d.x, d.y, 0).normalized()
	v *= velocity_scaling_with_distance * d.length() + velocity_const; 
	
	inst.altitude = altitude
	inst.global_position = global_position
	inst.throw(v)
	get_tree().get_root().add_child(inst)
	
	emit_signal("spawned", inst)
