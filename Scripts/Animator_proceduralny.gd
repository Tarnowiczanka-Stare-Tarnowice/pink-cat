extends Node
class_name Procedural_Animator

var previous_pos = Vector2.ZERO
var current_pos = Vector2.ZERO
var current_vel = Vector2.ZERO
var dynamic_constants = [0.0, 0.0, 0.0]

func _init(czestotliwosc_drgan := float(1), tlumienie := float(0), opoznienie_reakcji := float(0), pozycja_startowa := Vector2.ZERO):
	#^^ Nazwy po polsku, bo designerzy beda tego uzywac (oraz zeby latwiej zrozumiec)
	dynamic_constants[0] = tlumienie / (PI * czestotliwosc_drgan)
	dynamic_constants[1] = 1 / ((2 * PI * czestotliwosc_drgan) * (2 * PI * czestotliwosc_drgan))
	dynamic_constants[2] = opoznienie_reakcji * tlumienie / (2 * PI * czestotliwosc_drgan)
	
	previous_pos = pozycja_startowa
	current_pos = pozycja_startowa
	current_vel = Vector2.ZERO


func new_interpolated_position(vel_or_pos : bool, delta : float, target_pos : Vector2, target_vel = null) -> Vector2:
	if not target_vel is Vector2: #nie ma podanej predkasci, albo zostala zle podana
		target_vel = (target_pos - previous_pos) / delta
		previous_pos = target_pos
	var dc1_stable = max(dynamic_constants[1], 1.1 * (delta*delta/4 + delta*dynamic_constants[1]/2))
	current_pos = current_pos + delta * current_vel
	current_vel = current_vel + delta * (target_pos + dynamic_constants[2]*target_vel - current_pos - dynamic_constants[0]*current_vel) / dc1_stable
	if vel_or_pos == true:
		return current_pos
	else:
		return current_vel
