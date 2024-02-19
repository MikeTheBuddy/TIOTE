extends CharacterBody2D


const SPEED = 80.0

@onready var animated_sprite_2d = $AnimatedSprite2D

var last_direction = Vector2i()

@onready var attack_cooldown = $AttackCooldown

@onready var collision_shape_2d = $AttackRange/CollisionShape2D

@export var player_info: Resource

func _ready():
	position = player_info.position
	animated_sprite_2d.play("Idle_Down")
	
# updates the animation to the correct one based on some stuff
func update_animation():
	if velocity == Vector2.ZERO:
		if last_direction.x != 0:
			
			if last_direction.x == 1:
				animated_sprite_2d.flip_h = false
			elif last_direction.x == -1:
				collision_shape_2d.position.x = -9
				animated_sprite_2d.flip_h = true
			animated_sprite_2d.play("Idle_Forward")
		
		if last_direction.y != 0:
			if last_direction.y == 1:
				animated_sprite_2d.play("Idle_Down")
			elif last_direction.y == -1:
				animated_sprite_2d.play("Idle_Up")
	else:
		if abs(velocity.x) >= abs(velocity.y):
			if velocity.x > 0:
				animated_sprite_2d.flip_h = false
			elif velocity.x < 0:
				animated_sprite_2d.flip_h = true
			animated_sprite_2d.play("Walk_Forward")
		else:
			if velocity.y > 0:
				animated_sprite_2d.play("Walk_Down")
			elif velocity.y < 0:
				animated_sprite_2d.play("Walk_Up")

func _process(_delta):
	# Add the gravity.
	#if not is_on_floor():
	#		velocity.y += gravity * delta
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO and attack_cooldown.is_stopped():
		last_direction = direction
	
	if Input.is_action_just_pressed("Attack"):
		attack_cooldown.start()
		velocity = Vector2(0,0)
		match last_direction:
			Vector2(1,0):
				animated_sprite_2d.play("Attack_Foward")
				collision_shape_2d.position.x = 9
				collision_shape_2d.disabled = false
				animated_sprite_2d.flip_h = false
			Vector2(-1,0):
				animated_sprite_2d.play("Attack_Foward")
				collision_shape_2d.position.x = -9
				collision_shape_2d.disabled = false
				animated_sprite_2d.flip_h = true
				
	elif attack_cooldown.is_stopped():
		collision_shape_2d.disabled = true
		update_animation()
		velocity = direction * SPEED
	

	move_and_slide()