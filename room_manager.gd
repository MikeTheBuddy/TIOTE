extends Area2D

const POT = preload("res://pot.tscn")

const SLIME = preload("res://slime.tscn")
const SKELETON = preload("res://skeleton.tscn")

const SHOPITEM = preload("res://shop_item.tscn")

@export var layout_info: Resource

@onready var interactables = $Interactables
@onready var monsters = $Monsters
@onready var deload_buffer_area = $DeloadBufferArea

@onready var deload_time = $DeloadTime

enum ROOM_TYPE {Normal,Shop,Boss}

const SHOP_ITEM_LOCATIONS = [Vector2(-64,0),Vector2(64,0),Vector2(-64,48),Vector2(64,48)]

var active_pots = []

var active_monsters = []

var shop_items = []

var room_type: ROOM_TYPE

# THIS IS A TEMP SOLUTION FOR SHOP DELOADING
var shop_loaded = false

func _ready():
	match room_type:
		ROOM_TYPE.Normal:
			active_pots.resize(layout_info.pot_layout.size())
			active_pots.fill(false)
		
			active_monsters.resize(layout_info.monster_layout.size())
			active_monsters.fill(true)


func _on_body_entered(_body):
	#print(room_type)
	match room_type:
		ROOM_TYPE.Normal:
			load_room_normal()
		ROOM_TYPE.Shop:
			load_room_shop()
			
	

func load_room_normal():
	var counter = 0
	for i in layout_info.pot_layout:
		var pot = POT.instantiate()
		pot.position = Vector2(-168+i.x*16,-48+i.y*16)
		pot.broken = active_pots[counter]
		interactables.call_deferred("add_child",pot)
		counter += 1

	counter = 0
	
	var monster_num = 0
	
	for i in layout_info.monster_layout:
		if active_monsters[counter] == true:
			var monster = null
			match int(i.z): # (ID,x,y)
				0: # Slime
					monster = SLIME.instantiate()
					monster.name = "Slime" + str(monster_num)
					monster_num += 1
				1: # Skeleton
					monster = SKELETON.instantiate()
					monster.name = "Skeleton" + str(monster_num)
					monster_num += 1
					
					
			monster.position = Vector2(-168+i.x*16,-48+i.y*16)
			monsters.call_deferred("add_child",monster)
		
		counter += 1

func load_room_shop():
	#TODO MAKE SHOP ROOM LAYOUTS
	if shop_loaded == false:
		for x in SHOP_ITEM_LOCATIONS:
			shop_loaded = true
			var shopitem = SHOPITEM.instantiate()
			shopitem.position = x
			#print(shopitem.position)
			#shop_items.append(shopitem.)
			interactables.call_deferred("add_child",shopitem)

func _on_body_exited(_body):
	match room_type:
		ROOM_TYPE.Normal:
			deload_room_normal()

func deload_room_normal():
	deload_buffer_area.set_collision_layer_value(9,true)
	if deload_time.is_inside_tree():
		deload_time.start()
		await deload_time.timeout
		for i in range(0,interactables.get_child_count()):
			active_pots[i] = interactables.get_child(i).broken
			interactables.get_child(i).queue_free()
			
		for i in range(0,monsters.get_child_count()):
			active_monsters[i] = monsters.get_child(i).alive
			monsters.get_child(i).queue_free()
	deload_buffer_area.set_collision_layer_value(9,false)
