extends Control

#@onready var animation_player = $Wallet/AnimationPlayer
#@onready var wallet_timer = $Wallet/WalletTimer
#@onready var wallet = $Wallet
@onready var menu_ui = $MenuUI

const WALLETSPEED = 10

signal picked_up_coin
signal update_location
signal health_update_menu

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
	#print(self)
	update_location.emit()
	
	# clears the healthbar to replace the pips upon loading in
	for child in health_segments.get_children():
		child.queue_free()
	
	#print(health_segments.get_child_count())
	
	menu_ui.heal.connect(change_health)

func _process(_delta):
	if Input.is_action_just_pressed("DebugButton") and Gamestates.in_battle == false and Gamestates.in_transition == false:
		if in_menu == false:
			open_menu()
			in_menu = true
		else:
			close_menu()
			in_menu = false
	
	
	# Updating the running timer we are currently testing
	global_clock.text = str(Globaltime.minutes) + ":" + str(Globaltime.seconds) 

func open_menu():
	#print("OPENING MENU")
	match get_tree().current_scene.name:
		"Dungeon":
			get_tree().paused = true
		"Overworld":
			get_tree().paused = true
		"Interior":
			get_tree().paused = true
	menu_ui.call("show_menu")

func close_menu():
	#print("CLOSING MENU")
	match get_tree().current_scene.name:
		"Dungeon":
			get_node("/root/Dungeon/Player").get_tree().paused = false
		"Overworld":
			get_node("/root/Overworld/Player").get_tree().paused = false
		"Interior":
			get_node("/root/Interior/Player").get_tree().paused = false
	menu_ui.call("hide_menu")


func _on_update_location():
	match get_tree().current_scene.name:
		"Dungeon":
			location.text = "Dungeon | Floor " + str(get_node("/root/Dungeon").level)
		"Overworld":
			location.text = "Overworld"
			
	location_timer.start()





func change_health(change_value):
	var new_health = player_info.current_health + change_value
	
	if new_health < 0:
		new_health = 0
	elif new_health > player_info.max_health:
		new_health = player_info.max_health
	
	#var current_health = player_info.current_health
	player_info.current_health = new_health
	
	menu_ui.call("update_health")
