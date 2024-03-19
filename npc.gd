extends CharacterBody2D

@onready var sprite_2d = $Interact/Sprite2D
@onready var npc_animated_sprite = $NPCAnimatedSprite
@onready var label_animator = $Dialogue/LabelAnimator
@onready var box_animator = $BoxAnimator
@onready var dialogue = $Dialogue
@onready var skip_dialogue_text = $Dialogue/SkipDialogueText

# THIS WILL BE REPLACEDW WITH AN EXPORT
@onready var animation_list = ["00.test_text", "01.test_text", "02.test_text"]



var player_near: bool

var dialogue_index: int


func _ready():
	player_near = false
	dialogue_index = 0
	# DEFAULT IDLE FOR NOW
	npc_animated_sprite.play("idle")
	box_animator.play("default")



func _on_select_area_entered(_area):
	display_dialogue()
	
func display_dialogue():
	if dialogue_index == 0:
		sprite_2d.visible = false
		box_animator.play("pop_dialogue")
		await box_animator.animation_finished
	elif dialogue_index >= animation_list.size():
		box_animator.play_backwards("pop_dialogue")
		dialogue_index = 0
		await box_animator.animation_finished
		return
	if skip_dialogue_text.is_stopped():
		label_animator.play(animation_list[dialogue_index])
		dialogue_index += 1
		box_animator.play("visible_text")
		skip_dialogue_text.start()
	


func _on_interact_area_entered(_area):
	sprite_2d.visible = true
	player_near = true


func _on_interact_area_exited(_area):
	sprite_2d.visible = false
	player_near = false
	dialogue_index = 0
	#print(dialogue.scale.x)
	if clampf(dialogue.scale.x,0,0.3) == 0.3:
		box_animator.play_backwards("pop_dialogue")
