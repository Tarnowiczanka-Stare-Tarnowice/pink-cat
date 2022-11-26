extends Node2D


var brick = preload("res://Scenes/Brick.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if Input.is_action_just_pressed("ui_accept"):
		var inst = brick.instance()
		var v2d = get_global_mouse_position()-global_position
		var v = Vector3(v2d.x, v2d.y, 0) * 2
		inst.altitude = 200
		inst.global_position = global_position
		inst.throw(v)
		get_parent().add_child(inst)
