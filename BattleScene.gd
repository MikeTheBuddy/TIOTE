extends ColorRect

const battle_monster = preload("res://battle_monster.tscn")
const battle_player = preload("res://battle_player.tscn")

@export var monster_1: CharacterBody2D
@export var monster_2: CharacterBody2D
@export var monster_3: CharacterBody2D

@export var player_info: Resource

@export var first_strike: bool

@onready var turn_order = $TurnOrder
#@onready var target = $Target
@onready var options = $Options

@onready var player_location = $PlayerLocation
@onready var monster_1_location = $Monster1Location
@onready var monster_2_location = $Monster2Location
@onready var monster_3_location = $Monster3Location
@onready var animation_player = $AnimationPlayer

var select_monster = false

var focus = 1

# player is turn 0, monsters take turns 1-3
var turn = 0

var player_node: Node2D

var is_defending = false

signal change_health(change_value)

signal health_updated

func _ready():
	# show battle box
	scale = Vector2(0,0)
	animation_player.play("open_battle_screen")
	await animation_player.animation_finished
	
	var player = battle_player.instantiate()
	player.position = player_location.position
	player.turn_end.connect(next_turn)
	player.selecting_monsters.connect(selecting_monsters)
	player.defending.connect(defending)
	
	# saving the player's path for later
	player_node = player
	
	turn_order.add_child(player)
	
	# this is gross, change it later...
	if monster_1 != null:
		var monster = battle_monster.instantiate()
		var monster_info = identify_monster(monster_1)
		monster.get_node("Sprite2D").texture = monster_info[0]
		monster.stats = monster_info[1]
		monster.name = "monster1"
		monster.position = monster_1_location.position
		turn_order.add_child(monster)
		monster.turn_end.connect(next_turn)
		monster.damage_player.connect(handle_damage)
		
	if monster_2 != null:
		var monster = battle_monster.instantiate()
		var monster_info = identify_monster(monster_1)
		monster.get_node("Sprite2D").texture = monster_info[0]
		monster.stats = monster_info[1]
		monster.name = "monster2"
		monster.position = monster_2_location.position
		turn_order.add_child(monster)
		monster.turn_end.connect(next_turn)
		monster.damage_player.connect(handle_damage)
	
	if monster_3 != null:
		var monster = battle_monster.instantiate()
		var monster_info = identify_monster(monster_1)
		monster.get_node("Sprite2D").texture = monster_info[0]
		monster.stats = monster_info[1]
		monster.name = "monster3"
		monster.position = monster_3_location.position
		turn_order.add_child(monster)
		monster.turn_end.connect(next_turn)
		monster.damage_player.connect(handle_damage)

	# gives a free hit at the start of the fight if the player struck first
	if first_strike == true:
		first_strike_advantage()

	# start the battle - MAKE INTO A FUNCTION LATER
	turn_order.get_child(turn).call("turn_start")

# if you want to add more monsters to the game, you add their stuff here
func identify_monster(body: CharacterBody2D):
	var needed_information = []
	match body.ID:
		0: #Slime
			needed_information.append(load("res://Resources/BattleIcons/slime_battle_TEMP.png"))
			needed_information.append(load("res://Battle/MonsterStats/slime_stats.tres"))
	return needed_information


func _process(_delta):
	if select_monster == true:
		if Input.is_action_just_pressed("ui_up"):
			if focus <= 1:
				turn_order.get_child(focus).call("unfocus")
				focus = turn_order.get_child_count()-1
				turn_order.get_child(focus).call("focus")
			else:
				turn_order.get_child(focus).call("unfocus")
				focus -= 1
				turn_order.get_child(focus).call("focus")
		elif Input.is_action_just_pressed("ui_down"):
			if focus >= turn_order.get_child_count()-1:
				turn_order.get_child(focus).call("unfocus")
				focus = 1
				turn_order.get_child(focus).call("focus")
			else:
				turn_order.get_child(focus).call("unfocus")
				focus += 1
				turn_order.get_child(focus).call("focus")
	
		# crashes when 0 enemies are present, aka win condition
		#target.position = turn_order.get_child(focus).position + Vector2(25,-25)
	
		
func _on_attack_pressed():
	if select_monster == false:
		focus = 1 # REPLACE WITH FUNCTION TO IDENTIFY REMAINING MONSTERS
		#target.position = turn_order.get_child(focus).position + Vector2(25,-25)
		select_monster = true
		#target.visible = true
	else:
		options.visible = false
		select_monster = false
		#target.visible = false
		#TODO REPLACE THIS WITH AN ATTACK 
		turn_order.get_child(focus).call("take_damage",player_info.attack)
		await get_tree().create_timer(1).timeout
		next_turn()


func next_turn():
	# checks if the battle is over
	if turn_order.get_child_count() == 1:
		end_battle_win()
	elif player_info.current_health <= 0:
		if turn != 0:
			await health_updated
		end_battle_loss()
	else:
		if turn != 0:
			await health_updated
			#print("NEXT TURN")
		
		turn += 1
		# round back to the first person - player
		if turn > turn_order.get_child_count() - 1:
			turn = 0
			#print(turn)
			#print(turn_order.get_children())
		
		turn_order.get_child(turn).call("turn_start")

func end_battle_win():
	#print("BATTLE WON!")
	if monster_1 != null:
		monster_1.call("death")
		
	if monster_2 != null:
		monster_2.call("death")
	
	if monster_3 != null:
		monster_3.call("death")
	Gamestates.in_battle = false
	queue_free()

func end_battle_loss():
	print("DONE")
	Gamestates.in_battle = false
	queue_free()

func selecting_monsters(test):
	focus = 1 # sets it to the first active monster on the board
	match test:
		"Single":
			select_monster = true
			turn_order.get_child(focus).call("focus")
			player_node.get_node("Confirm").pressed.connect(single_attack)
			
			
func single_attack():
	select_monster = false
	turn_order.get_child(focus).call("unfocus")
	player_node.get_node("Confirm").pressed.disconnect(single_attack)
	turn_order.get_child(focus).call("take_damage",player_info.attack)
	await get_tree().create_timer(0.5).timeout
	next_turn()

func handle_damage(damage):
	# for now, damage is calculated as damage - defense = received damage
	var taken_damage = clampi(damage - player_info.defense, 0, 999)
	if is_defending == true:
		taken_damage = int(taken_damage/2.0)
	change_health.emit(-taken_damage)
	
	await health_updated


func gui_health_update(time):
	#print("WE CALLED UPDATED")
	await get_tree().create_timer(time).timeout
	health_updated.emit()

func defending(status):
	is_defending = status
	if is_defending == true:
		next_turn()

func first_strike_advantage():
	for monster_id in range(1,turn_order.get_child_count()):
		turn_order.get_child(monster_id).call("take_damage",player_info.attack)
