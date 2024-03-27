extends Node2D


@export var player_info: Resource
@onready var animation_player = $AnimationPlayer

signal turn_end
signal selecting_monsters(type)
signal defending(status)

func _ready():
	animation_player.play("idle_sword")

func turn_start():
	defending.emit(false)
	show_options()

func show_options():
	$Options.visible = true
	
func hide_options():
	$Options.visible = false

func _on_attack_pressed():
	hide_options()
	selecting_monsters.emit("Single")
	$Confirm.visible = true


func _on_confirm_pressed():
	$Confirm.visible = false




func _on_defend_pressed():
	hide_options()
	defending.emit(true)
	
