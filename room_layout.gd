extends Resource

class_name RoomLayout

@export var pot_layout: PackedVector2Array

@export var enemy_slime_layout: PackedVector2Array

func _init(p_pot_layout = [], p_enemy_slime_layout = []):
	pot_layout = p_pot_layout
	enemy_slime_layout = p_enemy_slime_layout
