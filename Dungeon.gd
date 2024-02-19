extends Node2D

var dungeon = {}

@onready var rooms = $Rooms

var node_sprite = load("res://Resources/Debug/map_nodes1.png")
var branch_sprite = load("res://Resources/Debug/map_nodes3.png")

var room_manager = load("res://room_manager.tscn")

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

@onready var tile_map = $TileMap
@onready var map_node = $Player/MapNode


func _ready():
	var rand_num = randi_range(0,2000)
	dungeon = DungeonGeneration.generate(rand_num)
	load_map()

func load_map():
	for i in range(0, map_node.get_child_count()):
		map_node.get_child(i).queue_free()
		
	for i in dungeon.keys():
		var temp = Sprite2D.new()
		temp.texture = node_sprite
		map_node.add_child(temp)
		temp.z_index = 1
		temp.position = i * 10
		
		var room_position_offset_x = i.x * 24
		var room_position_offset_y = i.y * 14
		
		# Here we are going to run some math to build the rooms properly
		for x in room_width_walls:
			for y in room_height_walls:
				dungeon_wall_tiles_arr.append(Vector2(x + room_width_walls_offset + room_position_offset_x,y + room_height_walls_offset + room_position_offset_y ))
				pass
				
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
	
	# here we are going to handle establishing each room
	for i in dungeon.keys():
		var room = room_manager.instantiate()
		room.name = "room_manager" + str(i)
		room.position = Vector2(i.x * 384,i.y * 224)
		
		rooms.add_child(room)
		
