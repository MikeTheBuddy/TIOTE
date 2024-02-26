extends Area2D

@export var teleport_information: Resource

const player_info_path = "res://player_info.tres"

@onready var player_info = preload(player_info_path)

@onready var sprite_2d = $Sprite2D

var entered = false

func _ready():
	sprite_2d.texture = teleport_information.teleport_texture_away
	
func _process(_delta):
	if Input.is_action_just_pressed("Interact") and entered == true:
		var scene = get_tree().current_scene.name
		match scene:
			"Overworld":
				player_info.money = get_node("/root/Overworld/Player").money
			"Dungeon":
				player_info.money = get_node("/root/Dungeon/Player").money
		
		player_info.position = teleport_information.teleport_position
		ResourceSaver.save(player_info,player_info_path)
		get_tree().change_scene_to_file(teleport_information.teleport_scene)






func _on_area_entered(_area):
	sprite_2d.texture = teleport_information.teleport_texture_close
	entered = true



func _on_area_exited(_area):
	sprite_2d.texture = teleport_information.teleport_texture_away
	entered = false
