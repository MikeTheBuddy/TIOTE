extends Area2D

@export var teleport_information: Resource

const player_info_path = "res://player_info.tres"

const PLAYER_COLLISION_LAYER = 8

@onready var player_info = preload(player_info_path)

@onready var sprite_2d = $Sprite2D

var entered = false

func _ready():
	sprite_2d.texture = teleport_information.teleport_texture_away


func _on_area_entered(area):
	sprite_2d.texture = teleport_information.teleport_texture_close
	entered = true
	if area.get_collision_layer_value(PLAYER_COLLISION_LAYER) == true:
		switch_scene()


func _on_area_exited(_area):
	sprite_2d.texture = teleport_information.teleport_texture_away
	entered = false


func switch_scene():
	#print("WHAT?")
	#var scene = get_tree().current_scene.name
	player_info.position = teleport_information.teleport_position
	get_tree().call_deferred("change_scene_to_file",teleport_information.teleport_scene)
	#get_tree().change_scene_to_file(teleport_information.teleport_scene)
