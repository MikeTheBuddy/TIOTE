extends Node2D


@export var player_info: Resource
@onready var animation_player = $AnimationPlayer
@onready var confirm = $Options/Confirm
@onready var options = $Options
@onready var attack = $Options/Attack
@onready var skills = $Options/Skills
@onready var defend = $Options/Defend
@onready var run = $Options/Run


signal turn_end
signal selecting_monsters(type)
signal cancel_selecting_monsters
signal defending(status)
signal running

func _ready():
	hide_options()
	confirm.visible = false
	animation_player.play("idle_sword")

func _process(_delta):
	if confirm.visible == true and Input.is_action_just_pressed("ui_left"):
		confirm.visible = false
		cancel_selecting_monsters.emit()
		show_options()
		attack.grab_focus()

func turn_start():
	defending.emit(false)
	show_options()
	attack.grab_focus()
	

func show_options():
	#options.visible = true
	attack.visible = true
	skills.visible = true
	defend.visible = true
	run.visible = true
	
func hide_options():
	#options.visible = false
	attack.visible = false
	skills.visible = false
	defend.visible = false
	run.visible = false

func _on_attack_pressed():
	hide_options()
	selecting_monsters.emit("Single")
	confirm.visible = true
	confirm.grab_focus()


func _on_confirm_pressed():
	confirm.visible = false


	

func _on_defend_pressed():
	hide_options()
	defending.emit(true)

func _on_run_pressed():
	hide_options()
	running.emit()


