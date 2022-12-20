extends KinematicBody2D
# MUST BE A CHILD NODE OF NAVIGATION2D NODE TO WORK



# velocity to be used in _physics_process, stored in a vector2
var _velocity := Vector2.ZERO

# path to player 
export var path_to_player := NodePath()
export var speed :=300.0

onready var _player := get_node(path_to_player)
onready var _agent: NavigationAgent2D = $NavigationAgent2D
#simple timer to update pathfinding
onready var _timer: Timer = $Timer
onready var _sprite: Sprite = $Sprite

func _ready() -> void:
	_update_pathfinding()
	#every time the clock times out, the pathfinding is updated with the new positon of target(player)
	_timer.connect("timeout",self,"_update_pathfinding")


func _physics_process(delta: float) -> void:
	#if enemy reaches target, the pathfinding finishes
	if _agent.is_navigation_finished():
		return
	
	#used for pathfinding
	var direction := global_position.direction_to(_agent.get_next_location()) 
	
	var desired_velocity := direction * speed
	var steering := (desired_velocity - _velocity) * delta * 4.0
	_velocity += steering
	
	_velocity = move_and_slide(_velocity)
	_sprite.rotation = _velocity.angle()

func _update_pathfinding() -> void:
	_agent.set_target_location(_player.global_position)
