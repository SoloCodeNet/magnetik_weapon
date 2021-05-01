extends KinematicBody2D

var direction:= Vector2.ZERO
var velocity := Vector2.ZERO
export(float) var speed := 170.0
export(float) var gravity := 1800.0
export(float) var jump_force:= -500
var snap := Vector2(0, 16)
var jump     := false
var jump_cnt := 0
var action1  := false
var action2  := false

var has_item := false
var is_item:=false
var item = null
var vector_line:= Vector2.ZERO
var force:= 500.0
var shake_force:=0.0

func _ready() -> void:
	$hand/AnimatedSprite.playing = true

func _physics_process(delta: float) -> void:
	snap= Vector2(0, 16)
	input_loop()
	player_physic(delta)
	animation_loop()
	
	
func animation_loop()->void:
	$Sprite.play("idle" if is_zero_approx(direction.x) else "walk")
	if get_global_mouse_position() > global_position: $Sprite.flip_h = false
	if get_global_mouse_position() < global_position: $Sprite.flip_h = true
	$hand.look_at(get_global_mouse_position())
	$cursor.global_position = get_global_mouse_position()
	vector_line = ($hand/Position2D.global_position - self.global_position).normalized()
	$hand/TextureProgress.value = force
	$hand/AnimatedSprite.visible = has_item

func player_physic(delta)->void:
	velocity.y += gravity * delta
	velocity.x = lerp(velocity.x,  direction.x * speed, 0.15)
	if is_on_floor():
		jump_cnt= 0
	if jump and jump_cnt < 2:
		snap = Vector2(0,0)
		velocity.y = jump_force
		jump_cnt+=1
	if abs(velocity.x) < 0.3: velocity.x = 0.0
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP, false,4, PI/4, false)
	gravity = 0.0 if is_on_floor() else 1800.0
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("body"):
			collision.collider.apply_central_impulse(-collision.normal *  100)

func input_loop()-> void:
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	jump = Input.is_action_just_pressed("ui_accept")

	if has_item and Input.is_action_pressed("action2"): 
		force+=30
		force = clamp(force, 500, 5000)
		if $hand/RayCast2D2.is_colliding(): force=500
		

	if has_item and Input.is_action_just_released("action2"):
		for x in $hand/Area2D.get_overlapping_bodies():
			if x.is_in_group("body") and x.grabbed and ! $hand/RayCast2D2.is_colliding():
				x.drop(vector_line * force)
				force = 500
				has_item = false
				
	var ok_grab = $hand/RayCast2D.is_colliding() and $hand/RayCast2D.get_collider().is_in_group("body")
	if is_item and Input.is_action_pressed("action1") and ok_grab:
		$Line2D.points = [Vector2.ZERO, item.global_position -self.global_position  ]
		shake_force+=0.5
		shake_force = min(shake_force, 100.0)
		item.shake(true, shake_force)
		print(shake_force)
		
		if shake_force == 50.0:
			for x in $hand/Area2D.get_overlapping_bodies():
				if x.is_in_group("body") and x.grabbed:
					print("on degage le premier")
					x.drop(vector_line * -2)
					
			$Line2D.points=[]
			shake_force =0.0
			item.shake(false, shake_force)
			item.pick(self)
			has_item = true

func _on_cursor_body_entered(body: Node) -> void:
	if body.is_in_group("body"):
		body.shake(false, 0.0)
		shake_force = 0.0
		$cursor/Sprite.modulate = Color.red
		is_item=true
		item = body

func _on_cursor_body_exited(body: Node) -> void:
	if body.is_in_group("body"):
		body.shake(false, 0.0)
		shake_force = 0.0
		$cursor/Sprite.modulate = Color.white
		is_item=false
		item = null
		$Line2D.points=[]
