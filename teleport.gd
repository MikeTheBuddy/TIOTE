extends Area2D

@export var teleport_information: Resource

const player_info_path = "res://player_info.tres"

const PLAYER_COLLISION_LAYER = 8

@onready var transition = $"../.."/GUILayer/Transition/AnimationPlayer
@onready var player = $"../.."/Player

@onready var player_info = preload(player_info_path)

@onready var sprite_2d = $Sprite2D

var entered = false

func _ready():
	sprite_2d.texture = teleport_information.teleport_texture_away


func _on_area_entered(area):
	sprite_2d.texture = teleport_information.teleport_texture_close
	if area.get_collision_layer_value(PLAYER_COLLISION_LAYER) == true:
		entered = true
		switch_scene()


func _on_area_exited(_area):
	if entered == false:
		sprite_2d.texture = teleport_information.teleport_texture_away


func switch_scene():
	#print("WHAT?")
	#var scene = get_tree().current_scene.name
	player_info.position = teleport_information.teleport_position
	
	#player.call_deferred("set_process_mode",PROCESS_MODE_DISABLED)
	#player.set_process_mode(PROCESS_MODE_DISABLED)
	
	Gamestates.in_transition = true
	transition.play("fade_out")
	await transition.animation_finished
	
	get_tree().call_deferred("change_scene_to_file",teleport_information.teleport_scene)
	#get_tree().change_scene_to_file(teleport_information.teleport_scene)
