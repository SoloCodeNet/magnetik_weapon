extends RigidBody2D

onready var parent= get_parent()
var player  = null
var grabbed := false
var is_shake := false
var force_shake:= 0.0

func _ready() -> void:
	add_to_group('body')

func pick(_pl)->void:
	player = _pl
	var pos = global_position
	mode = RigidBody2D.MODE_STATIC
	collision_layer = 2
	collision_mask  = 2
	parent.remove_child(self)
	player.add_child(self)
	global_position = pos
	grabbed = true
	
func drop(impulse = Vector2(0,0))->void:
	grabbed = false
	var pos = global_position
	player.remove_child(self)
	parent.add_child(self)
	global_position = pos
	mode = RigidBody2D.MODE_RIGID
	collision_layer = 1
	collision_mask = 1
	apply_central_impulse(impulse)
	
func _physics_process(delta: float) -> void:
	if is_shake:
		var v = Vector2(rand_range(-1, 1), rand_range(-1, 1)) *force_shake * rand_range(1.0, 3.0)
		apply_central_impulse(v)
	if !grabbed: return
	rotation += delta *10
	global_position = lerp(global_position, get_parent().get_node("hand/Position2D").global_position, 0.2)

func shake(_is_shake, _force_shake)->void:
	is_shake = _is_shake
	force_shake = _force_shake
