extends Area2D

@onready var item = $Item
@onready var animation_player = $AnimationPlayer
@onready var interact_radius = $InteractRadius
@onready var purchase_radius = $Purchase/PurchaseRadius
@onready var box_animator = $BoxAnimator
@onready var label_animator = $ItemDescription/LabelAnimator
@onready var item_description = $ItemDescription

const ITEM_CONSUMABLE_PATH = "res://Resources/Items/"

enum Item {Health_Potion_Small,Health_Potion_Medium,Health_Potion_Large}

enum Type {Dungeon_Shop,Overworld_Shop}

@export var restock: bool
@export var sold_out: bool

@export var player_info: Resource

@export var item_selling: Item
@export var shop_type: Type

var purchasing = false

var cost: int


# TODO PROTOTYPE WORKS... BUT CAN DEFINITELY BE BETTER

func _ready():
	animation_player.play("Floating")
	restock_item()


func disable_outline():
	item.material.set_shader_parameter("enable_shader",false)


func enable_outline():
	item.material.set_shader_parameter("enable_shader",true)


func _on_area_entered(_area):
	enable_outline()
	box_animator.play("pop_description_box")
	await box_animator.animation_finished
	box_animator.play("visible_text")



func _on_area_exited(_area):
	disable_outline()
	if purchasing == false:
		box_animator.play("close_description_box")

func disable_interaction():
	purchase_radius.set_deferred("disabled", true)
	interact_radius.set_deferred("disabled", true)

func enable_interaction():
	interact_radius.set_deferred("disabled", false)
	purchase_radius.set_deferred("disabled", false)

func _on_purchase_area_entered(_area):
	purchase_radius.set_deferred("disabled", true)
	if player_info.money < cost:
		# We will do something here too broke

		animation_player.play("Deny")
		animation_player.queue("Floating")
		
		var original_text = item_description.text
		#box_animator.stop()
		label_animator.play("money_description")
		await label_animator.animation_finished
		item_description.text = original_text
		purchase_radius.set_deferred("disabled", false)
		
	elif player_info.inventory.size() >= player_info.capacity:
		# We will do something if the inventory is full
		animation_player.play("Deny")
		animation_player.queue("Floating")
		
		var original_text = item_description.text
		box_animator.stop()
		label_animator.play("capacity_description")
		await label_animator.animation_finished
		item_description.text = original_text
		purchase_radius.set_deferred("disabled", false)
		
	else:
		player_info.money -= cost
		purchase_item()
	

func purchase_item():
	purchasing = true
	disable_interaction()
	player_info.inventory.push_front(item_selling)
	animation_player.play("Purchased")
	await animation_player.animation_finished
	box_animator.play_backwards("visible_text")
	await box_animator.animation_finished
	print("HERE")
	
	if restock == true:
		await get_tree().create_timer(0.3).timeout
		await restock_item()
		animation_player.play_backwards("Purchased")
		await animation_player.animation_finished
		box_animator.play("close_description_box")
		await box_animator.animation_finished
		enable_interaction()
		animation_player.play("Floating")
		purchase_radius.set_deferred("disabled", false)
	else:
		queue_free()
	
	purchasing = false

func restock_item():
	match shop_type:
		1: # Overworld_Shop
			var new_item = randi_range(0,Item.size()-1)
			set_item(new_item)


func set_item(item_ID):
	match item_ID:
		0:
			cost = 25
			item.texture = load(ITEM_CONSUMABLE_PATH+"health_potion_small.png")
			label_animator.play("health_potion_small_description")
		1:
			cost = 50
			item.texture = load(ITEM_CONSUMABLE_PATH+"health_potion_medium.png")
			label_animator.play("health_potion_medium_description")
		2:
			cost = 150
			item.texture = load(ITEM_CONSUMABLE_PATH+"health_potion_large.png")
			label_animator.play("health_potion_large_description")
	
	item_selling = item_ID
