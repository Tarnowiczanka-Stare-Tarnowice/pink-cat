extends Node2D

func _ready():
	$AnimationPlayer.play("Intro")

func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://UI/Menu/Menu.tscn")
