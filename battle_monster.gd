extends Node2D


signal turn_end
signal damage_player(damage)

@onready var animation_player = $AnimationPlayer
@onready var additional_sprite = $MonsterSprite/AdditionalSprite
@export var stats: Resource
@onready var health = $Health
@export var gradient: GradientTexture1D
@onready var monster_sprite = $MonsterSprite

var current_health: int

const ATTACKVECTOR2POS = Vector2(120, 120)

var original_pos: Vector2

var selected: bool


func _ready():
	current_health = stats.health
	health.max_value = stats.health
	#health.value = current_health
	original_pos = position
	additional_sprite.texture = stats.additional_sprite
	monster_sprite.sprite_frames = stats.monster_sprites
	
	#var test = stats.idle_animation
	await compile_combat_animations()
	#print(test)
	
	#print(test)
	#animation_player.add_animation_library("combat",stats.animation_track)
	#animation_player.play("target_bob")
	#print(original_pos)
	animation_player.play("combat/idle")
	

func compile_combat_animations():
	#print("WHAT")
	#print(stats.idle_animation.get_method_list())
	var combat_animation_library: AnimationLibrary = AnimationLibrary.new()
	combat_animation_library.add_animation("idle",stats.idle_animation)
	combat_animation_library.add_animation("attack",stats.attack_animation)
	combat_animation_library.add_animation("approach",stats.chase_animation)
	combat_animation_library.add_animation("death",stats.death_animation)
	animation_player.add_animation_library("combat",combat_animation_library)
	#print(animation_player.get_animation_library("combat"))

func turn_start():
	var tween = get_tree().create_tween()
	animation_player.play("combat/approach")
	tween.tween_property($".", "position", ATTACKVECTOR2POS, 0.8)
	await tween.finished
	animation_player.play("combat/attack")
	await animation_player.animation_finished
	
	
	
	tween = get_tree().create_tween()
	animation_player.play("combat/approach")
	tween.tween_property($".", "position", original_pos, 0.8)
	await tween.finished
	animation_player.play("combat/idle")
	turn_end.emit()


func take_damage(damage_taken):
	current_health -= (damage_taken-stats.defense)
	if current_health <= 0:
		death()
	health.value = current_health

func inflict_damage():
	damage_player.emit(stats.attack)

func focus():
	#focused = true
	#$Targeted.visible = true
	monster_sprite.material.set_shader_parameter("enable_shader",true)
	#print("FOCUSING ON" + str(name))

func unfocus():
	#$Targeted.visible = false
	#print("UNFOCUSING ON")
	monster_sprite.material.set_shader_parameter("enable_shader",false)

func death():
	animation_player.play("combat/death")
	await animation_player.animation_finished
	queue_free()
	await tree_exited
	



