extends Control

@onready var animation_player = $Wallet/AnimationPlayer
@onready var wallet_timer = $Wallet/WalletTimer
@onready var wallet = $Wallet

const WALLETSPEED = 10

signal picked_up_coin
signal update_location
signal shake_wallet

@onready var location_timer = $Location/LocationTimer
@onready var location = $Location


func _ready():
	update_location.emit()

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

func _on_picked_up_coin():
	wallet_timer.start()


func _on_update_location():
	if get_tree().current_scene.name == "Dungeon":
		location.text = "Dungeon | Floor " + str(get_node("/root/Dungeon").level)
	location_timer.start()


func _on_shake_wallet():
	animation_player.play("Wallet_Shake")
