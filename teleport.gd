extends Area2D

@export var teleport_information: Resource

const player_info_path = "res://player_info.tres"

@onready var player_info = preload(player_info_path)

@onready var sprite_2d = $Sprite2D

@onready var player = get_tree().get_first_node_in_group("Player")



var entered = false

func _ready():
	sprite_2d.texture = teleport_information.teleport_texture
	
func _process(_delta):
	if Input.is_action_just_pressed("Interact") and entered == true:
		player_info.position = teleport_information.teleport_position
		ResourceSaver.save(player_info,player_info_path)
		get_tree().change_scene_to_file(teleport_information.teleport_scene)






func _on_area_entered(_area):
	entered = true
	#print("TEST")



func _on_area_exited(_area):
	entered = false
