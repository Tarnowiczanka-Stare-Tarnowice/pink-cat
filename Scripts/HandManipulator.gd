extends Node2D

export var THROW_FORCE_MULTIPLIER = 1.3
export var self_mass = 2
export var max_carried_item_mass = 10
export var hand_accelleration: float = 2000
export var hand_altitude: float = 100
export var left_hand: bool = false

export var hand_range: int = 100
export var active_begin_angle_degrees: int = -95
export var active_end_angle_degrees: int = 95
export var rest_begin_angle_degrees: int = -115
export var rest_end_angle_degrees: int = 115

export var REST_SPEED_COEFFICIENT = 2.0
export var REST_EASE_COEFFICIENT = 0.5
export var REST_BEGIN_TIME = 2

var rest_time = 0
var rest_state_position
var throw_action
var shoot_action
var last_throw = 0
var shot_id = 0

# Liczba elementów oznacza "czas kojota" dla rzutu w klatkach
var throw_force_samples = [0,0,0,0,0,0]
var throw_force_samples_current = 0

var hand_speed = 0

var mouse_over = false
var grab_targets = []
var grabbed = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var angle = -PI/3
	throw_action = "right_throw"
	shoot_action = "right_shoot"
	if left_hand:
		throw_action = "left_throw"
		shoot_action = "left_shoot"
		angle = PI/3
	rest_state_position = Vector2(1,0).rotated(angle) * hand_range * 0.6
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var mouse_relative_position = get_local_mouse_position()
	var angle = rad2deg(mouse_relative_position.angle())
	
	# Docelowa pozycja ręki
	# ---------------------
	if angle > rest_begin_angle_degrees and angle < rest_end_angle_degrees: # Tryb śledzenia
		rest_time = 0
		var new_angle = clamp(angle, active_begin_angle_degrees, active_end_angle_degrees)
		mouse_relative_position = mouse_relative_position.rotated(deg2rad(new_angle - angle))
		
		if mouse_relative_position.length() > hand_range:
			mouse_relative_position = mouse_relative_position.normalized() * hand_range
		
	else: # Tryb spoczynku
		var lerp_coeff = delta * max(0, rest_time - REST_BEGIN_TIME) * REST_SPEED_COEFFICIENT
		mouse_relative_position = $Hand.position.linear_interpolate(rest_state_position, lerp_coeff)
		rest_time += delta * REST_EASE_COEFFICIENT
	
	# Kalkulacja pozycji/prędkości/etc ręki
	# ----------------------
	var old_position = $Hand.position
	
	var acceleration = hand_accelleration * self_mass / (self_mass + (grabbed.mass if grabbed else 0))
	
	hand_speed += acceleration * acceleration_scaler() * delta;
	hand_speed = min(hand_speed, 1400)
	$Hand.position = $Hand.position.move_toward(mouse_relative_position, delta * hand_speed)
	hand_speed = $Hand.position.distance_to(old_position) / delta
	
	throw_force_samples[throw_force_samples_current] = hand_speed;
	throw_force_samples_current = (throw_force_samples_current + 1) % throw_force_samples.size()
	var throw_force = throw_force_samples.max();
	
	$DebugArrow.modulate = Color(throw_force / 700, 1400 - throw_force/700,0)
	
	# Chwyt/rzut
	# -----------------
	if Input.is_action_just_pressed(throw_action) and last_throw < Time.get_ticks_msec() + 50:
		last_throw = Time.get_ticks_msec()
		if grabbed:
			var v2d = get_global_mouse_position() - $Hand.global_position
			v2d = v2d.normalized() * throw_force * THROW_FORCE_MULTIPLIER
			var v3d = Vector3(v2d.x, v2d.y, 0)
			grabbed.altitude = hand_altitude
			grabbed.throw(v3d)
			grabbed = null
		elif grab_targets.size() > 0:
			grabbed = get_grab_target()
			if grabbed.mass <= max_carried_item_mass:
				grabbed.grab($Hand)
			else:
				grabbed = null
		
	# Strzelanie
	# ----------
	if Input.is_action_just_pressed(shoot_action):
		shot_id += 1
	if Input.is_action_pressed(shoot_action) and grabbed and grabbed.has_method("shoot"):
		grabbed.shoot(shot_id)
	
	
	
	
	
func acceleration_scaler():
	return max(1, 10 - hand_speed)

func get_grab_target():
	return grab_targets[grab_targets.size()-1]


func _on_Hand_body_entered(body):
	if not grab_targets.has(body) and body.has_method("grab") and body.has_method("throw"):
		grab_targets.append(body)


func _on_Hand_body_exited(body):
	grab_targets.erase(body)


func _on_Hand_mouse_entered():
	mouse_over = true


func _on_Hand_mouse_exited():
	mouse_over = false
