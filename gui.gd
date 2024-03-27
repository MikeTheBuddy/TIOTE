extends Control

@onready var animation_player = $Wallet/AnimationPlayer
@onready var wallet_timer = $Wallet/WalletTimer
@onready var wallet = $Wallet
@onready var menu_ui = $MenuUI

const WALLETSPEED = 10

signal picked_up_coin
signal update_location
signal shake_wallet
signal health_updated(time)

@onready var location_timer = $Location/LocationTimer
@onready var location = $Location
#@onready var health = $PlayerBars/Health

@onready var global_clock = $GlobalClock
@onready var health_segments = $HealthSegments

@export var player_info:Resource

var in_menu = false

func _ready():
	#health.max_value = player_info.max_health
	#health.value = player_info.current_health
	update_location.emit()
	
	# clears the healthbar to replace the pips upon loading in
	for child in health_segments.get_children():
		child.queue_free()
	
	#print(health_segments.get_child_count())
	
	# fills the new healthbar based on max and current health
	for health_point in range(1,player_info.max_health+1):
		var color_rect = ColorRect.new()
		color_rect.name = "pip_" + str(health_point)
		color_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		if health_point <= player_info.current_health:
			color_rect.color = Color.RED
		else:
			color_rect.color = Color.DARK_RED
		
		health_segments.add_child(color_rect)

	var health_size_formula = roundi((1.0 / (player_info.max_health+1))*150)


	health_segments.size.x = health_size_formula*player_info.max_health - 1
	
	#print(health_segments.size.x)


func _process(_delta):
	if wallet_timer.is_stopped() == false:
		wallet.position.y = move_toward(wallet.position.y, 192, 3)
		wallet.visible = true
	else:
		wallet.position.y = move_toward(wallet.position.y, 220, 3)
		if wallet.position.y == 220:
			wallet.visible = true
		
	if location_timer.is_stopped() == false:
		location.position.y = move_toward(location.position.y, 0, 3)
		location.visible = true
	else:
		location.position.y = move_toward(location.position.y, -25, 3)
		if location.position.y == -25:
			location.visible = true

	#DEBUG TO TEST INCREASING HEALTH
	if Input.is_action_just_pressed("ui_focus_next"):
		change_health(15)
			
	if Input.is_action_just_pressed("DebugButton") and Gamestates.in_battle == false:
		if in_menu == false:
			open_menu()
			in_menu = true
		else:
			close_menu()
			in_menu = false

	# Updating the running timer we are currently testing
	global_clock.text = str(Globaltime.minutes) + ":" + str(Globaltime.seconds) 

func open_menu():
	print("OPENING MENU")
	match get_tree().current_scene.name:
		"Dungeon":
			get_tree().paused = true
		"Overworld":
			get_tree().paused = true
	menu_ui.call("show_menu")

func close_menu():
	print("CLOSING MENU")
	match get_tree().current_scene.name:
		"Dungeon":
			get_node("/root/Dungeon/Player").get_tree().paused = false
		"Overworld":
			get_node("/root/Overworld/Player").get_tree().paused = false
	menu_ui.call("hide_menu")
func _on_picked_up_coin():
	wallet_timer.start()


func _on_update_location():
	match get_tree().current_scene.name:
		"Dungeon":
			location.text = "Dungeon | Floor " + str(get_node("/root/Dungeon").level)
		"Overworld":
			location.text = "Overworld"
			
	location_timer.start()


func _on_shake_wallet():
	animation_player.play("Wallet_Shake")



func change_health(change_value):
	var new_health = player_info.current_health + change_value
	
	if new_health < 0:
		new_health = 0
	elif new_health > player_info.max_health:
		new_health = player_info.max_health
	
	#var current_health = player_info.current_health
	player_info.current_health = new_health
	
	#if current_health > new_health:
	#	await decrease_health_animation()
	#else:
	#	await increase_health_animation()
	#print("FINISHED")
	#clampf(delay,2,10)
	health_updated.emit(3)

func decrease_health_animation():
	for health_point in range(player_info.max_health-1,-1,-1):
		#print("Check")
		if health_point <= player_info.current_health - 1:
			break
		else:
			if health_segments.get_child(health_point).color != Color.DARK_RED:
				await get_tree().create_timer(0.075).timeout
			health_segments.get_child(health_point).color = Color.DARK_RED
	#print("FINISHED")
	
func increase_health_animation():
	
	for health_point in range(0,player_info.max_health):
		if health_point > player_info.current_health - 1:
			break
		else:
			if health_segments.get_child(health_point).color != Color.RED:
				await get_tree().create_timer(0.075).timeout
			health_segments.get_child(health_point).color = Color.RED
