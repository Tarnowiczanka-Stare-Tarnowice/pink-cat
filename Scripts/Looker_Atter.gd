extends Node2D


export (NodePath) var target = ".."
export (bool) var looking_at_mouse = true
export (int) var dir_correction = 1
export var enable = true
var tgt

func _ready():
	tgt = get_node(target)

func _process(delta):
	if not enable:
		return
	if looking_at_mouse:
		if global_position.distance_squared_to(get_global_mouse_position()) > 1:
			look_at(get_global_mouse_position())
			rotate(dir_correction * PI/2)
	else:
		if global_position.distance_squared_to(tgt.global_position) > 1:
			look_at(tgt.global_position)
			rotate(dir_correction * PI/2)
