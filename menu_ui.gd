extends Control

const INVENTORY_ITEM = "res://inventory_item.tscn"

@onready var health_bar = $MenuBlock/HealthBar
#@onready var item_drop_down = $MenuBlock/Items/ItemDropDown
@onready var item_drop_down = $ItemDropDown
@onready var health_value = $MenuBlock/HealthBar/HealthValue

@export var player_info: Resource

func _ready():
	update_health()
	update_inventory()

func update_inventory():
	for child in item_drop_down.get_children():
		item_drop_down.remove_child(child)
		
	for x in range(0,player_info.capacity):
		var item = load(INVENTORY_ITEM).instantiate()
		#print(player_info.inventory.size())
		if player_info.inventory.size()-1 < x:
			item.item_ID = -1
		else:
			item.item_ID = player_info.inventory[x]
			
		item_drop_down.add_child(item)

func update_health():
	health_bar.max_value = player_info.max_health
	health_bar.value = player_info.current_health
	health_value.text = str(player_info.current_health) + "/" + str(player_info.max_health)


func hide_menu():
	visible = false
	item_drop_down.visible = false
	
func show_menu():
	visible = true


func _on_items_pressed():
	if item_drop_down.visible == true:
		item_drop_down.visible = false
	else:
		update_inventory()
		item_drop_down.visible = true

