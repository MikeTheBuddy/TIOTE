extends Node2D

var dungeon = {}

@onready var rooms = $Rooms
@onready var map = $GUILayer/Map

var node_sprite = load("res://Resources/Debug/map_nodes1.png")
var node_sprite_shop = load("res://Resources/Debug/map_nodes2.png")
var node_sprite_player = load("res://Resources/Debug/map_nodes_player.png")
var branch_sprite = load("res://Resources/Debug/map_nodes3.png")

var room_manager = load("res://room_manager.tscn")

var battle_scene = load("res://battle_scene.tscn")

var dungeon_floor_tiles_arr = []
var dungeon_floor_int = 0
var dungeon_floor_layer = 1

var dungeon_wall_tiles_arr = []
var dungeon_wall_int = 1
var dungeon_wall_layer = 2

var dungeon_door_wall_tiles_arr = []

var dungeon_source_id = 0

var dungeon_terrain_set_id = 1

var room_width_walls = 24
var room_height_walls = 14

var room_width_floors = 22
var room_height_floors = 10

var room_width_walls_offset = -12
var room_height_walls_offset = -7

var room_width_floors_offset = -11
var room_height_floors_offset = -4

var verticle_door_width = 3
var verticle_door_height = 4

var horizontal_door_width = 4
var horizontal_door_height = 2

@onready var transition = $GUILayer/Transition/AnimationPlayer
@onready var tile_map = $TileMap
@onready var map_node = $GUILayer/Map
@onready var dungeon_rooms = $Rooms

enum Room_Type {Normal,Shop,Boss}

var level = 1

signal generate_dungeon
signal engage_battle(monster_1,monster_2,monster_3)

func _ready():
	generate_dungeon.emit()
	transition.play("fade_in")
	await transition.animation_finished
	Gamestates.in_transition = false

func load_map():
	for i in range(0, map_node.get_child_count()):
		map_node.get_child(i).queue_free()
	
	for i in range(0,dungeon_rooms.get_child_count()):
		dungeon_rooms.get_child(i).queue_free()
	
	var offset_x = 0
	var offset_y = 0
	
	for i in dungeon.keys():
		var temp = Sprite2D.new()
		temp.name = str(i)
		temp.texture = node_sprite
		map_node.add_child(temp)
		temp.z_index = 1
		temp.position = i * 10
		
		if i[0] < offset_x:
			offset_x = i[0]
		
		if i[1] < offset_y:
			offset_y = i[1]
		
		var room_position_offset_x = i.x * 24
		var room_position_offset_y = i.y * 14
		
		# Here we are going to run some math to build the rooms properly
		for x in room_width_walls:
			for y in room_height_walls:
				dungeon_wall_tiles_arr.append(Vector2(x + room_width_walls_offset + room_position_offset_x,y + room_height_walls_offset + room_position_offset_y ))
				
		for x in room_width_floors:
			for y in room_height_floors:
				dungeon_floor_tiles_arr.append(Vector2(x + room_width_floors_offset + room_position_offset_x, y + room_height_floors_offset + room_position_offset_y))
		
		var c_rooms = dungeon.get(i).connected_rooms
		if(c_rooms.get(Vector2(1, 0)) != null):
			temp = Sprite2D.new()
			temp.texture = branch_sprite
			map_node.add_child(temp)
			temp.z_index = 0
			temp.position = i * 10 + Vector2(5, 0.5)
			
			# this is for handling the flooring between rooms horizontally
			for x in horizontal_door_width:
				for y in horizontal_door_height:
					dungeon_floor_tiles_arr.append(Vector2i(x + 10 + room_position_offset_x,y + room_position_offset_y))
			
			# this is for handling the doors horizontally
			for x in range(2):
				for y in range(6):
					dungeon_door_wall_tiles_arr.append(Vector2i(x + 11 + room_position_offset_x,y + room_position_offset_y - 3))
			
		if(c_rooms.get(Vector2(0, 1)) != null):
			temp = Sprite2D.new()
			temp.texture = branch_sprite
			map_node.add_child(temp)
			temp.z_index = 0
			temp.rotation_degrees = 90
			temp.position = i * 10 + Vector2(-0.5, 5)
			
			# this is for handling the flooring between rooms vertically
			for x in verticle_door_width:
				for y in verticle_door_height:
					dungeon_floor_tiles_arr.append(Vector2i(x - 1 + room_position_offset_x,y + 6 + room_position_offset_y))
					#tile_map.set_cell(dungeon_wall_layer,Vector2i(x - 1,y + 6 + room_position_offset_y),dungeon_source_id,Vector2(4,12))
			
			# this is for the doorways vertically
			for x in range(5):
				for y in range(2):
					dungeon_door_wall_tiles_arr.append(Vector2i(x - 2 + room_position_offset_x,y + 6 + room_position_offset_y))
					
		tile_map.set_cells_terrain_connect(dungeon_floor_layer,dungeon_floor_tiles_arr,dungeon_terrain_set_id,dungeon_floor_int)
		dungeon_floor_tiles_arr = []
		
		tile_map.set_cells_terrain_connect(dungeon_wall_layer,dungeon_wall_tiles_arr,dungeon_terrain_set_id,dungeon_wall_int)
		dungeon_wall_tiles_arr = []	
	
	tile_map.set_cells_terrain_connect(dungeon_wall_layer,dungeon_door_wall_tiles_arr,dungeon_terrain_set_id,dungeon_wall_int)
	
	# We are gonna adjust the position of the map node to show the full map
	#print(offset_x)
	#print(offset_y)
	map.pivot_offset.x = -20 + 15*offset_x
	map.pivot_offset.y = -20 + 15*offset_y
	
	
	# create the playermarker node
	var temp_player = Sprite2D.new()
	temp_player.name = "PlayerMarker"
	temp_player.texture = node_sprite_player
	map_node.add_child(temp_player)
	temp_player.z_index = 1
	
	# here we are going to handle establishing each room
	var shop_generated = false
	
	# this will help to ensure a shop is always generated
	var shop_chance_increaser = 0
	
	for i in dungeon.keys():
		
		var rand_num = randi_range(0,len(dungeon.keys())-shop_chance_increaser - 1)
		if shop_generated == false and rand_num == 0:
			shop_generated = true
			generate_room_shop(i)
			map.find_child(str(i),true,false).texture = node_sprite_shop
			
			#print("SHOP MADE: " + str(i))
		else:
			generate_room_normal(i)
		shop_chance_increaser += 1

func generate_room_normal(room_num):
	var room = room_manager.instantiate()
	room.name = "room_manager" + str(room_num)
	room.position = Vector2(room_num.x * 384,room_num.y * 224)
	room.room_type = Room_Type.Normal
	var random_layout = randi_range(1,2)
	room.layout_info = load("res://Dungeon/dungeon_layout_basic_" + str(random_layout) + ".tres")
	rooms.add_child(room)

func generate_room_shop(room_num):
	var room = room_manager.instantiate()
	room.name = "room_manager" + str(room_num)
	room.position = Vector2(room_num.x * 384,room_num.y * 224)
	room.room_type = Room_Type.Shop
	rooms.add_child(room)

func _on_generate_dungeon():
	var rand_num = randi_range(0,2000)
	dungeon = DungeonGeneration.generate(rand_num)
	load_map()
	get_node("GUILayer/GUI").update_location.emit()



func _on_engage_battle(monster_1, monster_2, monster_3, first_strike):
	if Gamestates.in_battle == false:
		Gamestates.in_battle = true
		var battle = battle_scene.instantiate()
		battle.first_strike = first_strike
		battle.monster_1 = monster_1
		battle.monster_2 = monster_2
		battle.monster_3 = monster_3
		battle.change_health.connect(get_node("GUILayer/GUI").change_health)
		#get_node("GUILayer/GUI").health_updated.connect(battle.gui_health_update)
		$GUILayer.add_child(battle)
