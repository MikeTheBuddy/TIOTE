extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $BreakRange/CollisionShape2D

@export var broken: bool

func _ready():
	if broken == false:
		animated_sprite_2d.play("Unbroken")
	else:
		animated_sprite_2d.play("Broken")
		collision_shape_2d.set_deferred("disabled", true)
		
func _on_break_range_area_entered(_area):
	if broken == false:
		animated_sprite_2d.play("Breaking")
		broken = true
		collision_shape_2d.set_deferred("disabled", true)
	
