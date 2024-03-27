extends CharacterBody2D

var chase = false

var player = null

var alive = true

const ID = 0

const SPEED = 800

const FRICTION = 200

@onready var animation_player = $AnimationPlayer

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $ChaseRadius/CollisionShape2D
@onready var assist_radius = $AssistRadius
@onready var collision_box = $CollisionBox
@onready var hitbox = $Hitbox
@onready var monster_sprite = $MonsterSprite

func _ready():
	#animated_sprite_2d.play("Idle")
	animation_player.play("slime_idle")
	
func _physics_process(delta):
	if chase and Gamestates.in_battle == false:
		"""if player.global_position.x > global_position.x:
			animated_sprite_2d.flip_h = false
		else:
			animated_sprite_2d.flip_h = true"""
		if monster_sprite.scale.x > 1.15:
			velocity += (player.global_position - global_position).normalized() * SPEED * delta
		else:
			apply_friction(5)
		
		#global_position += (player.global_position - global_position).normalized() * SPEED * delta
		move_and_slide()
	else:
		apply_friction(5)
		move_and_slide()
	#print(jump_timer)
	
func _on_chase_radius_body_entered(body):
	#animated_sprite_2d.play("Jump")
	animation_player.play("slime_chase")
	player = body
	chase = true


func _on_chase_radius_body_exited(_body):
	#animated_sprite_2d.play("Idle")
	animation_player.play("slime_idle")
	player = null
	chase = false

func death():
	collision_box.set_deferred("disabled", true)
	hitbox.set_deferred("monitoring", false)
	alive = false
	visible = false

# this only activates if the player hit with their weapon
func _on_hitbox_area_entered(area):
	if area.name == "AttackRange":
		var battle_enemies = assist()
		
		get_node("/root/Dungeon").engage_battle.emit(battle_enemies[0],battle_enemies[1],battle_enemies[2],true)


func assist():
	# THIS WILL BE UPDATED IN THE FUTURE
	hitbox.set_deferred("monitoring", false)
	var battle_enemies = assist_radius.get_overlapping_bodies()
	
	while battle_enemies.size() > 3:
		battle_enemies.pop_back()
		
	while battle_enemies.size() < 3:
		battle_enemies.append(null)
	return battle_enemies

# this only activates if the player runs into the monster
func _on_hitbox_body_entered(_body):
	var battle_enemies = assist()
	get_node("/root/Dungeon").engage_battle.emit(battle_enemies[0],battle_enemies[1],battle_enemies[2],false)


func apply_friction(amount) -> void:
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO
