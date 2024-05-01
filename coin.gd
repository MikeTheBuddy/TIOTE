extends Area2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var fall_time = $FallTime
@onready var collision_shape_2d = $CollisionShape2D
@onready var animation_player = $AnimationPlayer

@onready var player = get_node("/root/Dungeon/Player")

@export var player_info: Resource

const player_info_path = "res://player_info.tres"

const GRAVITY = 9.8

const RESIST_X = 0.04

const PURSE_LOCATION = Vector2(175,100)

var velocity_x = 0
var velocity_y = 0

var collected = false

func _ready():
	#constant_linear_velocity.x = randi_range(-10,10)
	#constant_linear_velocity.y = -80
	velocity_x = randf_range(-1,1)
	velocity_y = randf_range(-1,-0.8)
	
	var value = get_meta("value")
	
	if value == 1:
		animated_sprite_2d.play("coin_bronze")
	
	if value == 5:
		animated_sprite_2d.play("coin_silver")
	
	if value == 10:
		animated_sprite_2d.play("coin_gold")
	
	animated_sprite_2d.set_frame(randi_range(0,5))
	
	fall_time.start()
	
func _process(delta):
	if fall_time.is_stopped() == false:
		if collected == false:
			position.x += velocity_x
			position.y += velocity_y

		velocity_x = move_toward(velocity_x,0,RESIST_X)
		velocity_y += GRAVITY * delta
	else:
		collision_shape_2d.disabled = false
		set_process(false)


func _on_area_entered(_area):
	animation_player.play("collected")
	#collision_shape_2d.set_deferred("disabled",true)
	


func _on_animation_player_animation_finished(_anim_name):
	player_info.money += get_meta("value")
	
	z_index = 200
	get_node("/root/Dungeon/GUILayer/GUI").picked_up_coin.emit()
	queue_free()
	
