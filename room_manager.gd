extends Area2D

const POT = preload("res://pot.tscn")

const SLIME = preload("res://slime.tscn")

@export var layout_info: Resource

@onready var interactables = $Interactables
@onready var monsters = $Monsters

@onready var deload_time = $DeloadTime

var active_pots = []

var active_monsters = []

func _ready():
	active_pots.resize(layout_info.pot_layout.size())
	active_pots.fill(false)
	
	active_monsters.resize(layout_info.monster_layout.size())
	active_monsters.fill(true)


func _on_body_entered(_body):
	#print("Room " + str(position) + " Was Entered")
	#print(active_pots)
	var counter = 0
	for i in layout_info.pot_layout:
		var pot = POT.instantiate()
		pot.position = Vector2(-168+i.x*16,-48+i.y*16)
		pot.broken = active_pots[counter]
		interactables.call_deferred("add_child",pot)
		counter += 1

	counter = 0
	for i in layout_info.monster_layout:
		if active_monsters[counter] == true:
			var monster = null
			match int(i.z):
				0:
					monster = SLIME.instantiate()
		
		
			monster.position = Vector2(-168+i.x*16,-48+i.y*16)
			monsters.call_deferred("add_child",monster)
		
		counter += 1


func _on_body_exited(_body):
	if deload_time.is_inside_tree():
		deload_time.start()
		await deload_time.timeout
		for i in range(0,interactables.get_child_count()):
			active_pots[i] = interactables.get_child(i).broken
			interactables.get_child(i).queue_free()
			
		for i in range(0,monsters.get_child_count()):
			active_monsters[i] = monsters.get_child(i).alive
			monsters.get_child(i).queue_free()

	#print("Room " + str(position) + " Was Exited")
