extends Node2D


onready var  kid = $"Arm_joint"

var joint_array = []
var test_array = []
var mouseposition
var angle

func calculate_normal(base, target):
	target -= base
	return target.normalized()
# Called when the node enters the scene tree for the first time.
func _ready():
	while(kid!= null):
		joint_array.append(kid)
		kid = kid.get_child(0)
	for i in 4:
		test_array.append(Vector2(0,0))
	single_solve(Vector2(7,7)) 



		
		
func single_solve(target):
	var init_start = test_array[0]
	print(test_array.size())
	test_array[test_array.size() - 1] = target
	for i in range (test_array.size() - 2, -1, -1):
		var move_vector = 100 * calculate_normal(test_array[i+1], test_array[i])
		test_array[i] = test_array[i+1] + move_vector
		print(str(test_array[i]))
	test_array[0] = init_start
	for i in range (1, test_array.size()):
		var move_vector = 100 * calculate_normal(test_array[i-1], test_array[i])
		test_array[i] = test_array[i-1] + move_vector
		print(str(test_array[i]))
	for i in range (0, test_array.size()):
		joint_array[i].global_position = test_array[i]
		
			
		
func _process(delta):
	if Input.is_action_pressed("click"):
		mouseposition = get_global_mouse_position()
		single_solve(mouseposition)
	pass
	
