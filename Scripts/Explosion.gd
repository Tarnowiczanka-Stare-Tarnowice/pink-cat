extends Area2D

export var max_force = 3000;
export var radius = 100;

var explode_now = false

func _ready():
	$CollisionShape2D.shape.radius = radius

# Funkcja skalująca siłę wybuchu, zmienić według upodobania
func force_falloff(distance):
	return pow(lerp(0, sqrt(max_force), distance/radius), 2)

func set_radius(new_radius):
	radius = new_radius
	$CollisionShape2D.shape.radius = radius

func _process(_delta):
	# Wymagana 1 klatka opóźnienia by upewnić się, że kolizje będą poprawnie obsłużone
	if not explode_now:
		explode_now = true
		return
		
	for i in get_overlapping_bodies():
		if i.has_method('hit'):
			var pos_relative = i.global_position - global_position
			var d = pos_relative.length()
			var force = pos_relative.normalized() * force_falloff(d)
			
			i.hit(Vector3(force.x, force.y, 0), 1, 1, force.normalized())
	queue_free()
