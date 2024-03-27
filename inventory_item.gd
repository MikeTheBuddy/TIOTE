extends Button

const ITEM_UI_ICON_PATH = "res://UIElements/"

enum Item {Health_Potion_Small,Health_Potion_Medium,Health_Potion_Large,EMPTY = -1}

@export var item_ID: Item

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
