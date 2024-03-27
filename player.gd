extends CharacterBody2D

# DEBUG REMOVE LATER
@onready var label = $Label

const ACCELERATION = 1000
const FRICTION = 1200
const MAX_SPEED = 60.0

@onready var animated_sprite_2d = $AnimatedSprite2D

var last_direction = Vector2i()

@onready var attack_cooldown = $AttackCooldown
@onready var collision_shape_2d = $AttackRange/CollisionShape2D
@export var player_info: Resource

const player_info_path = "res://player_info.tres"

var lockout = false # currently only used for room transitions to prevent the player from causing issues with the loading
var swing_lockout = false

enum {IDLE, WALK, SWING}

#var state = IDLE

@onready var animation_tree = $AnimationTree
@onready var state_machine  = animation_tree["parameters/playback"]

var blend_position : Vector2 = Vector2.ZERO
var blend_pos_paths = [
	"parameters/idle/idle_bs2d/blend_position",
	"parameters/walk/walk_bs2d/blend_position",
	"parameters/swing/swing_bs2d/blend_position"
]
var animTree_state_keys = [
	"idle",
	"walk",
	"swing"
]

var money : int
var max_health : int
var current_health : int

func _ready():
	position = player_info.position
	#animated_sprite_2d.play("Idle_Down")
	money = player_info.money
	max_health = player_info.max_health
	current_health = player_info.current_health
	
# updates the animation to the correct one based on some stuff
"""func update_animation():
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
	
	if lockout == false and Gamestates.in_battle == false:
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

	move_and_slide()"""

func _process(_delta):
	animate()
	#player_info.money = money
	#label.text = "Health: " + str(player_info.current_health)
	#label.text = "Money: " + str(player_info.money)
	label.text = str(player_info.inventory)

func _physics_process(delta):
	#print(velocity)
	if Gamestates.in_battle == false and swing_lockout == false:
		move(delta)

func move(delta):
	var input_vector = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	if input_vector == Vector2.ZERO:
		apply_friction(FRICTION * delta)
	else:
		apply_movement(input_vector * ACCELERATION * delta)
		blend_position = input_vector
	move_and_slide()

func apply_friction(amount) -> void:
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO
		
func apply_movement(amount) -> void:
	apply_friction(10)
	velocity += amount
	velocity = velocity.limit_length(MAX_SPEED)

func animate() -> void:
	#state_machine.travel(animTree_state_keys[state])
	#animation_tree.set(blend_pos_paths[state], blend_position)
	if velocity == Vector2.ZERO:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else: 
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
		
	if Input.is_action_just_pressed("Attack") and swing_lockout == false:
		swing_lockout = true
		attack_cooldown.start()
		state_machine.travel(animTree_state_keys[SWING])
		#animation_tree["parameters/conditions/swing"] = true
		
	#else:
	#	animation_tree["parameters/conditions/swing"] = false
		
	animation_tree.set(blend_pos_paths[IDLE], blend_position)
	animation_tree.set(blend_pos_paths[WALK], blend_position)
	animation_tree.set(blend_pos_paths[SWING], blend_position)




func _on_attack_cooldown_timeout():
	swing_lockout = false
