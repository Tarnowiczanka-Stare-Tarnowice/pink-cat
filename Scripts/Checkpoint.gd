class_name Checkpoint
extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Checkpoint_body_entered(body):
	if body.has_method("set_checkpoint"):
		body.set_checkpoint(global_position)
