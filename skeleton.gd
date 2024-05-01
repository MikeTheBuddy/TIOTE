extends CharacterBody2D

const ID = 1

const SPEED = 1200

var player = null

@onready var move_timer = $MoveTimer
@onready var animation_player = $AnimationPlayer

@onready var collision_shape_2d = $ChaseRadius/CollisionShape2D
@onready var assist_radius = $AssistRadius
@onready var collision_box = $CollisionBox
@onready var hitbox = $Hitbox
@onready var monster_sprite = $MonsterSprite

var alive = true

func _physics_process(delta):
	if player != null and move_timer.is_stopped():
		move_timer.start()
		velocity = Vector2.ZERO
		await get_tree().create_timer(0.15).timeout
		identify_direction_of_player(delta)
	
	move_and_slide()


func identify_direction_of_player(delta):
	var distance_vector = player.global_position-global_position
	if abs(distance_vector.x) > abs(distance_vector.y):
		if distance_vector.x > 0:
			#print("RIGHT")
			animation_player.play("Move_Right")
			velocity += Vector2(SPEED * delta,0)
		else:
			#print("LEFT")
			animation_player.play("Move_Left")
			velocity += Vector2(-SPEED * delta,0)
	else:
		if distance_vector.y > 0:
			#print("DOWN")
			animation_player.play("Move_Down")
			velocity += Vector2(0,SPEED * delta)
		else:
			#print("UP")
			animation_player.play("Move_Up")
			velocity += Vector2(0,-SPEED * delta)

func _on_chase_radius_body_entered(body):
	player = body

func assist():
	# THIS WILL BE UPDATED IN THE FUTURE
	var battle_enemies: Array[Node2D] = assist_radius.get_overlapping_bodies()
	
	# eliminate additional enemies to limit it to 3
	while battle_enemies.size() > 3:
		battle_enemies.pop_back()
	
	# fill blank spaces with placeholders
	while battle_enemies.size() < 3:
		battle_enemies.append(null)
	
	return battle_enemies

func death():
	alive = false
	manage_active_state(false)
	visible = false

func _on_hitbox_area_entered(area):
	if area.name == "AttackRange":
		var battle_enemies = assist()
		
		#print(battle_enemies)
		#manage_active_state(false)
		
		get_node("/root/Dungeon").engage_battle.emit(battle_enemies[0],battle_enemies[1],battle_enemies[2],true)



func _on_hitbox_body_entered(body):
	if body.name == "Player" and body.immunity == false:
		var battle_enemies = assist()
	
		#manage_active_state(false)
		get_node("/root/Dungeon").engage_battle.emit(battle_enemies[0],battle_enemies[1],battle_enemies[2],false)


func manage_active_state(active):
	set_physics_process(active)
	hitbox.set_deferred("monitoring",active)
