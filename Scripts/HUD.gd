extends CanvasLayer

export var mech_path: NodePath
onready var mech = get_node(mech_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HealthBar.max_value = mech.max_hp
	$HealthBar.value = mech.hp
	
	pass
