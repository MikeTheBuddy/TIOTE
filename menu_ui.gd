extends Control

const INVENTORY_ITEM = "res://inventory_item.tscn"

@onready var health_bar = $MenuBlock/HealthBar
#@onready var item_drop_down = $MenuBlock/Items/ItemDropDown
@onready var item_drop_down = $ItemDropDown
@onready var health_value = $MenuBlock/HealthBar/HealthValue
@onready var items = $MenuBlock/Items
@onready var attack_stat = $PlayerStats/AttackStat
@onready var defense_stat = $PlayerStats/DefenseStat
@onready var money_stat = $PlayerStats/MoneyStat
@onready var player_stats = $PlayerStats


@export var player_info: Resource

signal heal(value:int)

func _ready():
	update_health()
	update_inventory()

func update_inventory():
	for child in item_drop_down.get_children():
		item_drop_down.remove_child(child)
	
	var counter_ID = 0
	
	for x in range(0,player_info.capacity):
		var item = load(INVENTORY_ITEM).instantiate()
		#print(player_info.inventory.size())
		if player_info.inventory.size()-1 < x:
			item.item_ID = -1
			item.inventory_ID = -1
		else:
			item.heal.connect(heal_player)
			item.update_inventory.connect(update_inventory)
			item.item_ID = player_info.inventory[x]
			item.inventory_ID = counter_ID
			counter_ID += 1
		
		item_drop_down.add_child(item)
		
	item_drop_down.get_child(0).grab_focus()
	
func update_health():
	health_bar.max_value = player_info.max_health
	health_bar.value = player_info.current_health
	health_value.text = str(player_info.current_health) + "/" + str(player_info.max_health)


func hide_menu():
	visible = false
	item_drop_down.visible = false
	
func show_menu():
	items.grab_focus()
	visible = true

func _on_items_pressed():
	if item_drop_down.visible == true:
		item_drop_down.visible = false
	else:
		update_inventory()
		item_drop_down.visible = true

func heal_player(value):
	heal.emit(value)



func _on_stats_pressed():
	if player_stats.visible == false:
		attack_stat.text = "Attack:" + str(player_info.attack)
		defense_stat.text = "Defense:" + str(player_info.defense)
		money_stat.text = "Money:" + str(player_info.money)
		player_stats.visible = true
	else:
		player_stats.visible = false
