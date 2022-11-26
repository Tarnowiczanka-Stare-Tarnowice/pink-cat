extends KinematicBody2D

export var velocity: Vector3 = Vector3()
export var altitude: float = 0
export var mass: float = 1
export var bounciness: float = 0.4
export var friction: float = 3
# If set, the object will collide with aerial objects when on ground
export var tall: bool = false


const shadow_projection_vector = Vector2(0.2, 0.1)
const gravity = 980.0

const aerial_collision_layer = 2;
const ground_collision_layer = 1;
const aerial_collision_mask = 2;
const ground_collision_mask = 1;

signal hit


# Called when the node enters the scene tree for the first time.
func _ready():
	update_collision_mask()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	
	var total_friction = 0
	
	# grawitacja
	velocity.z -= gravity * delta;
	
	# Obsługa wysokości
	altitude += velocity.z * delta;
	if altitude < 0:
		altitude = 0
		velocity.z = 0
		total_friction = friction * friction_scaler(velocity)
	
	update_collision_mask()
	
	# Tarcie
	velocity -= velocity.normalized() * total_friction * delta
	
	# Prosty cien, prawdopodobnie do zmiany
	$ShadowSlot.position = altitude * shadow_projection_vector
	
	var collision = move_and_collide(velocity2D() * delta)
	if collision:
		if collision.collider.has_method("hit"):
			velocity = collision.collider.hit(velocity, mass, bounciness, collision.normal)
		else: # Proste odbicie się jak od ściany z zadaną sprężystością
			var newv = velocity2D().bounce(collision.normal)
			newv -= newv.project(collision.normal) * (1-bounciness)
		
			# Zapisanie wektora 2D do komponentów x,y wektora 3D
			velocity.x = newv.x
			velocity.y = newv.y



func velocity2D():
	return Vector2(velocity.x, velocity.y)

func throw(new_velocity):
	velocity = new_velocity

# Źródła:
# https://en.wikipedia.org/wiki/Elastic_collision
# Rozszerzenie dla kolizji nieelastycznych: https://www.youtube.com/watch?v=r7l0Rq9E8MY
# ale przynajmniej działa
func hit(other_velocity: Vector3, other_mass: float, other_bounciness: float, other_normal: Vector2) -> Vector3:
	var m1 = mass
	var m2 = other_mass
	var v1 = velocity
	var v2 = other_velocity
	var cr = (bounciness + other_bounciness)/2
	var n = Vector3(other_normal.x, other_normal.y, 0)
	
	velocity = v1 - (1+cr)*m2/(m1+m2) * (v1-v2).dot(n) / n.length() / n.length() * n
	emit_signal("hit", self, mass * (velocity - v1).length_squared()/2);
	return v2 - (1+cr)*m1/(m1+m2) * (v2-v1).dot(-n) / n.length() / n.length() * -n


# Ewentualne skalowanie tarcia dla ładniejszego efektu
func friction_scaler(velocity):
	if velocity.length() < 900:
		return 100 + velocity.length()
	return 1000

func update_collision_mask():
	if tall:
		collision_layer = ground_collision_layer | aerial_collision_layer
		collision_mask = ground_collision_mask | aerial_collision_mask
	elif altitude <= 0:
		collision_layer = ground_collision_layer
		collision_mask = ground_collision_mask
	else:
		collision_layer = aerial_collision_layer
		collision_mask = aerial_collision_mask
	
