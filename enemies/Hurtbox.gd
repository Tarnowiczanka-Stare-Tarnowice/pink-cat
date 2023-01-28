class_name Hurtbox
extends Area2D

#Hurtbox is a custom-made area2D that detects Hitboxes and pases the hitbox
#damage value to the take_damage method of the owner(if there is one)

func _init() -> void:
	
	#the layer of the objects it should colide with( 0 means none)
	collision_layer = 0
	#the layer of the Hitbox collision_layer
	collision_mask = 2

func _ready() ->void:
	connect("area_entered",self,"_on_area_entered")

func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null:
		return
	
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
	
