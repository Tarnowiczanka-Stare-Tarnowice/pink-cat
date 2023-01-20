extends KinematicBody2D
# MUST BE A CHILD NODE OF NAVIGATION2D NODE TO WORK

# velocity to be used in _physics_process, stored in a vector2
var _velocity := Vector2.ZERO

# path to player 
export var path_to_player := NodePath()
export var speed := 300.0
export var HP := 100.0
#time for which the enemy will be stuned after being attacked
export var stun_time = 0.5

onready var _player := get_node(path_to_player)
onready var _agent: NavigationAgent2D = $NavigationAgent2D
#simple timer to update pathfinding
onready var _timer: Timer = $Timer
#timer to count down the stun time
onready var _stun_timer: Timer = $Stuntimer
onready var _sprite: Sprite = $Sprite
onready var _health_bar: ProgressBar = $healthBar

func _ready() -> void:
	_update_pathfinding()

	_health_bar.value = HP
	#every time the clock times out, the pathfinding is updated with the new positon of target(player)
	_timer.connect("timeout",self,"_update_pathfinding")


func _physics_process(delta: float) -> void:
	#if enemy reaches target, the pathfinding finishes
	if _agent.is_navigation_finished():
		return
		
	#deletes enemy if HP goes below zero
	if HP<=0:
		queue_free()
	
	
	#used for pathfinding
	var direction := global_position.direction_to(_agent.get_next_location()) 
	
	var desired_velocity := direction * speed
	var steering := (desired_velocity - _velocity) * delta * 4.0
	_velocity += steering
	
	_sprite.rotation = _velocity.angle()
	
	#zeros the velocity vetor while enemy is stunned
	if _stun_timer.get_time_left()>0:
		_velocity=Vector2.ZERO
	
	_velocity = move_and_slide(_velocity)
	

func _update_pathfinding() -> void:
	_agent.set_target_location(_player.global_position)

#is responsible for changing HP amount after hit and starting the stun timer
func take_damage(amount: float) -> void:
	HP -= amount
	_health_bar.value = HP
	_stun_timer.start(stun_time)

