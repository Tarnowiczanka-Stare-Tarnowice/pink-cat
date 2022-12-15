extends KinematicBody2D

export var velocity: Vector3 = Vector3()
export var altitude: float = 0
export var mass: float = 1
export var bounciness: float = 0.4
export var friction: float = 3
# Gdy ustawiona, obiekt na ziemi będzie kolidował z obiektami w powietrzu
export var tall: bool = false
var grabber: Node2D = null

# Reguluje pozycję węzła cienia. Aby dodać cień, należy wrzucić jego grafikę jako dziecko węzła ShadowSlot
const shadow_projection_vector = Vector2(0.2, 0.1)
const gravity = 980.0

# TODO: Można zastanowić się, czy kolizje przedmiotów w powietrzu to dobry pomysł
const aerial_collision_layer = 2;
const aerial_collision_mask = 2;
const ground_collision_layer = 1;
const ground_collision_mask = 1;

signal hit


# Called when the node enters the scene tree for the first time.
func _ready():
	update_collision_mask()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	
	if grabber:
		global_position = grabber.global_position
		update_collision_mask()
		return
	
	var total_friction = 0
	
	# Grawitacja
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
	
	# Prosty cien
	$ShadowSlot.position = altitude * shadow_projection_vector
	
	var collision = move_and_collide(velocity2D() * delta)
	if collision:
		if collision.collider.has_method("hit"):
			velocity = collision.collider.hit(velocity, mass, bounciness, collision.normal)
			emit_signal("hit", self, mass * (velocity - collision.collider.velocity).length_squared()/2)
		else: # Proste odbicie się jak od ściany z zadaną sprężystością
			var newv = velocity2D().bounce(collision.normal)
			newv -= newv.project(collision.normal) * (1-bounciness)
		
			# Zapisanie wektora 2D do komponentów x,y wektora 3D
			velocity.x = newv.x
			velocity.y = newv.y
			


func grab(parent: Node2D):
	grabber = parent

func velocity2D():
	return Vector2(velocity.x, velocity.y)

func throw(new_velocity: Vector3):
	velocity = new_velocity
	grabber = null

# Obsługa kolizji dwóch obiektów. Modyfikuje prędkość samego siebie i zwraca prędkość drugiego obiektu
# Źródła:
# https://en.wikipedia.org/wiki/Elastic_collision
# Rozszerzenie dla kolizji nieelastycznych: https://www.youtube.com/watch?v=r7l0Rq9E8MY
# ale przynajmniej działa
func hit(other_velocity: Vector3, other_mass: float, other_bounciness: float, other_normal: Vector2) -> Vector3:
	var m1 = mass
	var m2 = other_mass
	var v1 = velocity
	var v2 = other_velocity
	# Można ewentualnie poeksperymentować z cr - współczynnikiem sprężystości odbicia
	var cr = (bounciness + other_bounciness)/2
	var n = Vector3(other_normal.x, other_normal.y, 0)
	
	velocity = v1 - (1+cr)*m2/(m1+m2) * (v1-v2).dot(n) / n.length() / n.length() * n
	emit_signal("hit", self, mass * (velocity - v1).length_squared()/2);
	return v2 - (1+cr)*m1/(m1+m2) * (v2-v1).dot(-n) / n.length() / n.length() * -n

# Ewentualne skalowanie tarcia dla ładniejszego efektu
func friction_scaler(v):
	if v.length() < 900:
		return 100 + v.length()
	return 1000

func update_collision_mask():
	if grabber:
		collision_layer = 0
		collision_mask = 0
	elif altitude > 0:
		collision_layer = aerial_collision_layer
		collision_mask = aerial_collision_mask
	elif tall:
		collision_layer = ground_collision_layer | aerial_collision_layer
		collision_mask = ground_collision_mask | aerial_collision_mask
	else:
		collision_layer = ground_collision_layer
		collision_mask = ground_collision_mask
