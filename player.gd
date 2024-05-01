extends CharacterBody2D

# DEBUG REMOVE LATER
@onready var label = $Label

const ACCELERATION = 1000
const FRICTION = 1200
const MAX_SPEED = 60.0


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

var immunity = false

func _ready():
	position = player_info.position
	#animated_sprite_2d.play("Idle_Down")
	money = player_info.money
	max_health = player_info.max_health
	current_health = player_info.current_health

func _process(_delta):
	if Gamestates.in_battle == false:
		animate()
	#player_info.money = money
	#label.text = "Health: " + str(player_info.current_health)
	#label.text = "Money: " + str(player_info.money)
	label.text = str(player_info.inventory)

func _physics_process(delta):
	#print(velocity)
	if Gamestates.in_battle == false and swing_lockout == false and Gamestates.in_transition == false:
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


func immunity_time(time):
	immunity = true
	await get_tree().create_timer(time).timeout
	immunity = false


func _on_attack_cooldown_timeout():
	swing_lockout = false
