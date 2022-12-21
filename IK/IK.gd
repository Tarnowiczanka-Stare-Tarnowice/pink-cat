extends Node2D

#Preloading a node variable for initialisation function
onready var  kid = $"Arm_joint"

#Array for storing the joint nodes
var joint_array = []
#Array that holds the positions for the IK algorithm
var test_array = []
var mouseposition
var angle

export (float) var joint_length = 20
export (NodePath) var arms_target = "."
var is_active = true
var target_ref = self


#Calculating the base of the move vector
func calculate_normal(base, target):
	target -= base
	return target.normalized()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# loading joints into the array
	target_ref = get_node(arms_target)
	while(kid!= null):
		joint_array.append(kid)
		if(kid.get_child_count() > 0):
			kid = kid.get_child(0)
		else:
			kid = null
	#initialising the test_array with neutral positions
	for i in 4:
		test_array.append(Vector2(0,0))



		
#IK algorithm (FABRIK single pass)
func single_solve(target):
	#initial position of the first joint, used to make the limb not fly off if the target is further than the length of the arm
	var init_start = global_position
	#print(test_array.size())
	test_array[test_array.size() - 1] = target
	#FABRIK "backwards" part
	for i in range (test_array.size() - 2, -1, -1):
		var move_vector = joint_length * calculate_normal(test_array[i+1], test_array[i])
		test_array[i] = test_array[i+1] + move_vector
		#print(str(test_array[i]))
	test_array[0] = init_start
	#FABRIK "forwards" part
	for i in range (1, test_array.size()):
		var move_vector = joint_length * calculate_normal(test_array[i-1], test_array[i])
		test_array[i] = test_array[i-1] + move_vector
		#print(str(test_array[i]))
	#Applying new positions to joints
	for i in range (0, test_array.size()):
		joint_array[i].global_position = test_array[i]
		
	for i in range (test_array.size() - 2, 0, -1):
		joint_array[i].look_at(joint_array[i-1].global_position)
		joint_array[i].rotate(-PI/2)
			
		
	
func _process(delta):
	#Trigger FABRIK when the left mouse button is pressed/held
	if is_active:
		single_solve(target_ref.global_position)
	pass
	
