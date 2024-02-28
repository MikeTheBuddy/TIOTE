extends CharacterBody2D

# DEBUG REMOVE LATER
@onready var label = $Label

const SPEED = 80.0

@onready var animated_sprite_2d = $AnimatedSprite2D

var last_direction = Vector2i()

@onready var attack_cooldown = $AttackCooldown

@onready var collision_shape_2d = $AttackRange/CollisionShape2D

@export var player_info: Resource

const player_info_path = "res://player_info.tres"

var lockout = false # currently only used for room transitions to prevent the player from causing issues with the loading

var money = 0

var max_health = 0
var current_health = 0

func _ready():
	position = player_info.position
	animated_sprite_2d.play("Idle_Down")
	money = player_info.money
	max_health = player_info.max_health
	current_health = player_info.current_health
	
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
	#print(lockout)
	# update money total
	player_info.money = money
	
	label.text = "Money: " + str(player_info.money)
	
	if lockout == false:
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

	#THIS IS PURELY FOR DEBUGGING DUNGEONS
	if Input.is_action_just_pressed("DebugButton"):
		get_node("/root/Dungeon/").level += 1
		get_node("/root/Dungeon/").generate_dungeon.emit()

	move_and_slide()
