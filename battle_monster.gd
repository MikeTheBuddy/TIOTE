extends Node2D


signal turn_end
signal damage_player(damage)

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@export var stats: Resource
@onready var health = $Sprite2D/Health
@onready var targeted = $Targeted

var current_health: int

const ATTACKVECTOR2POS = Vector2(120, 120)

var original_pos: Vector2

var selected: bool

func _ready():
	current_health = stats.health
	health.max_value = stats.health
	health.value = current_health
	original_pos = position
	sprite_2d.texture = stats.sprite
	selected = true # CHANGE TO FALSE AFTER DEBUG
	#position = Vector2.ZERO
	
	animation_player.play("target_bob")
	#print(original_pos)

func turn_start():
	var tween = get_tree().create_tween()
	tween.tween_property($".", "position", ATTACKVECTOR2POS, 0.8)
	await tween.finished
	await get_tree().create_timer(0.2).timeout
	attack()
	await get_tree().create_timer(0.2).timeout
	tween = get_tree().create_tween()
	tween.tween_property($".", "position", original_pos, 0.8)
	await tween.finished
	turn_end.emit()


func take_damage(damage_taken):
	current_health -= (damage_taken-stats.defense)
	if current_health <= 0:
		death()
	health.value = current_health


func attack():
	sprite_2d.modulate = Color.RED
	damage_player.emit(stats.attack)
	await get_tree().create_timer(0.3).timeout
	sprite_2d.modulate = Color.WHITE

func focus():
	$Targeted.visible = true

func unfocus():
	$Targeted.visible = false

func death():
	queue_free()
	await tree_exited
	



