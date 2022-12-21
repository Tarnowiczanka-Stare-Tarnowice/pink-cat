extends Node2D

export (NodePath) var target_leg = "."
var target : Node2D
onready var segment_fixed = $Segment_Fixed
onready var segment_stretching = $Segment_Fixed/Segment_Stretching
onready var leg_end = $LegEnd

var stretch_baseline
var stretch1
var current_dst
var current_stretch

var from_fixed_to_stretch

func _ready():
	from_fixed_to_stretch = segment_fixed.global_position.distance_to(segment_stretching.global_position)
	stretch1 = segment_stretching.get_child(0).scale.x
	stretch_baseline = leg_end.global_position.distance_to(segment_stretching.global_position)
	target = get_node(target_leg)

func _process(delta):
	segment_fixed.look_at(target.global_position)
	segment_fixed.rotate(PI/2)
	current_dst = segment_fixed.global_position.distance_to(target.global_position)
	current_dst -= from_fixed_to_stretch
	#ZASTAPIC POZYCJA LEG END, ZEBY NIE BYLO PIERWIASTKA
	current_stretch = current_dst
	#print(current_stretch/stretch_baseline)
	segment_stretching.scale.y = current_stretch/stretch_baseline
	#print(segment_stretching.scale.y)
