class_name Hitbox
extends Area2D

#Hitbox is a custom-made type of area2D used to give objects the ability to 
#call the take_damage signal on an impacted hurtbox

export var damage := 10.0

func _init() -> void:
	#The layer of the Hitbox 
	collision_layer = 2
	#the layer of the objects it should colide with( 0 means none)
	collision_mask = 0
