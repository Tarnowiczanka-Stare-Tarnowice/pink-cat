extends Node2D

export var pointer_coefficient = 0.2
export var move_inertia_coefficient = 0.92

var move_inertia = Vector2(0,0)
onready var previous_position = global_position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mousepos = get_viewport().get_mouse_position() - get_viewport().size/2
	move_inertia *= move_inertia_coefficient
	move_inertia += previous_position - global_position
	$Camera2D.position = position + move_inertia + mousepos * pointer_coefficient
	
	previous_position = global_position
