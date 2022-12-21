extends Node2D
class_name Pile

export(PackedScene) var object;

# Wysyłany po stworzeniu obiektu, jako argument przekazywana jest instancja nowego obiektu 
signal spawned

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func grab(grabber):
	var inst = object.instance()
	inst.global_position = global_position
	get_tree().get_root().add_child(inst)
	emit_signal("spawned", inst)
	return inst.grab(grabber)
