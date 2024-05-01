extends Node2D

@onready var player = $Player
@onready var interior_camera = $InteriorCamera
@onready var transition = $GUILayer/Transition/AnimationPlayer

func _ready():
	transition.play("fade_in")
	await transition.animation_finished
	Gamestates.in_transition = false

func _on_shop_body_entered(_body):
	print("UPDATED SHOP")
	interior_camera.position = Vector2(0,0)
	

func _on_home_body_entered(_body):
	print("UPDATED")
	interior_camera.position = Vector2(384,0)
