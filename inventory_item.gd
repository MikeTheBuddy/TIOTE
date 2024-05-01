extends Button

const ITEM_UI_ICON_PATH = "res://UIElements/"

enum Item {Health_Potion_Small,Health_Potion_Medium,Health_Potion_Large,EMPTY = -1}

@export var player_info: Resource

@export var item_ID: Item
@export var inventory_ID: int

signal heal(value:int)
signal update_inventory

func _ready():
	display_info()

func display_info():
	match item_ID:
		-1:
			$ItemIcon.texture = load(ITEM_UI_ICON_PATH+"empty_UI.png")
			$ItemName.text = "Empty"
		0:
			$ItemIcon.texture = load(ITEM_UI_ICON_PATH+"health_potion_small_UI.png")
			$ItemName.text = "Health Potion S"
		1:
			$ItemIcon.texture = load(ITEM_UI_ICON_PATH+"health_potion_medium_UI.png")
			$ItemName.text = "Health Potion M"
		2:
			$ItemIcon.texture = load(ITEM_UI_ICON_PATH+"health_potion_large_UI.png")
			$ItemName.text = "Health Potion L"
		_:
			$ItemName.text = "MISSING ITEM"


func healing_item(value):
	use_item()
	heal.emit(value)

func use_item():
	item_ID = Item.EMPTY
	print(inventory_ID)
	$ItemIcon.texture = load(ITEM_UI_ICON_PATH+"empty_UI.png")
	$ItemName.text = "Empty"
	if inventory_ID != -1:
		player_info.inventory.remove_at(inventory_ID)
		update_inventory.emit()
	else:
		print("ERROR DELETING ITEM...")

func _on_pressed():
	match item_ID:
		-1:
			print("NO ITEM")
		0:
			healing_item(5)
		1:
			healing_item(15)
		2:
			healing_item(25)
		_:
			print("MISSING ITEM")
