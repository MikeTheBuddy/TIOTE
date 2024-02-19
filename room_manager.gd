extends Area2D

const POT = preload("res://pot.tscn")

@export var layout_info: Resource

@onready var interactables = $Interactables

var active_pots = []

func _ready():
	active_pots.resize(layout_info.pot_layout.size())
	active_pots.fill(false)
	

func _on_body_entered(_body):
	print("Room " + str(position) + " Was Entered")
	print(active_pots)
	var counter = 0
	for i in layout_info.pot_layout:
		var pot = POT.instantiate()
		pot.position = Vector2(-168+i.x*16,-48+i.y*16)
		pot.broken = active_pots[counter]
		interactables.call_deferred("add_child",pot)
		counter += 1


func _on_body_exited(_body):
	for i in range(0,interactables.get_child_count()):
		active_pots[i] = interactables.get_child(i).broken
		interactables.get_child(i).queue_free()
	
	print("Room " + str(position) + " Was Exited")
