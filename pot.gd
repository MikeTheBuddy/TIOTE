extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $BreakRange/CollisionShape2D
@onready var drops = $Drops

@export var broken: bool

const COIN = preload("res://coin.tscn")

func _ready():
	if broken == false:
		animated_sprite_2d.play("Unbroken")
	else:
		collision_shape_2d.set_deferred("disabled", true)
		animated_sprite_2d.play("Broken")
		
func _on_break_range_area_entered(_area):
	if broken == false:
		collision_shape_2d.set_deferred("disabled", true)
		animated_sprite_2d.play("Breaking")
		broken = true
		# generate 1-3 random coins
		var coin_gen = randi_range(0,3)
		for _i in range(0,coin_gen):
			var coin = COIN.instantiate()
			var coin_rarity = randi_range(1,100)
			
			if coin_rarity <= 60:
				coin.set_meta("value",1)
			elif coin_rarity <= 95:
				coin.set_meta("value",5)
			else:
				coin.set_meta("value",10)
			
			drops.call_deferred("add_child",coin)
