extends Area2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var fall_time = $FallTime
@onready var collision_shape_2d = $CollisionShape2D

@onready var player = get_node("/root/Dungeon/Player")

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
	velocity_y = -1
	
	var value = get_meta("value")
	
	if value == 1:
		animated_sprite_2d.play("coin_bronze")
	
	if value == 5:
		animated_sprite_2d.play("coin_silver")
	
	if value == 10:
		animated_sprite_2d.play("coin_gold")
	
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

	if collected == true:
		var target_position = get_node("/root/Dungeon/CameraSnap").position + PURSE_LOCATION
		
		var speed_x = abs(target_position.x-global_position.x)/10
		var speed_y = abs(target_position.y-global_position.y)/10
		
		global_position.x = move_toward(global_position.x, target_position.x, speed_x)
		global_position.y = move_toward(global_position.y, target_position.y, speed_y)
		
		if round(global_position) >= target_position - Vector2(3,3):
			get_node("/root/Dungeon/GUILayer/GUI").shake_wallet.emit()
			queue_free()
			


func _on_body_entered(_body):
	if collected != true:
		player.money += get_meta("value")
		#print(get_meta("value"))
	
	collected = true
	#collision_shape_2d.set_deferred("disabled",true)
	z_index = 200
	get_node("/root/Dungeon/GUILayer/GUI").picked_up_coin.emit()
