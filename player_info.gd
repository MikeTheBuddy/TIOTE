extends Resource

class_name PlayerInformation

@export_category("Position")
@export var position : Vector2

@export_category("Player Stats")
@export var max_health : int
@export var current_health : int
@export var money: int
@export var experience: int
@export var attack: int
@export var defense: int

enum Item {Health_Potion_Small,Health_Potion_Medium,Health_Potion_Large}

@export_category("Inventory")
@export var inventory: Array[Item]
@export var capacity: int
