extends Camera2D

var camera_room_position = Vector2(0,0)
#@onready var player = $"../Player"
@onready var player = $"/root/Dungeon/Player"
@onready var transition_time = $TransitionTime
@onready var map = $"../GUILayer/Map"


const CAMSPEED = 10

const ROOM_WIDTH = 384.0
const ROOM_HEIGHT = 224.0

var direction: Vector2

func _process(_delta):
	var player_x_room = 0
	var player_y_room = 0
	
	if player.position.x < 0:
		player_x_room = int((player.position.x-ROOM_WIDTH/2)/ ROOM_WIDTH)
	else:
		player_x_room = int((player.position.x+ROOM_WIDTH/2)/ ROOM_WIDTH)
	
	if player.position.y < 0:
		player_y_room = int((player.position.y-ROOM_HEIGHT/2) / ROOM_HEIGHT)
	else:
		player_y_room = int((player.position.y+ROOM_HEIGHT/2) / ROOM_HEIGHT)
		
	var player_room_pos = Vector2(player_x_room,player_y_room)
	
	if camera_room_position != player_room_pos:
		camera_room_position = player_room_pos
		map.find_child("PlayerMarker",true,false).position = camera_room_position * 10
	
	#player_marker.position = camera_room_position
	
	
	var previous_position = position
	#position.x = move_toward(position.x, camera_room_position.x*ROOM_WIDTH, CAMSPEED)
	#position.y = move_toward(position.y, camera_room_position.y*ROOM_HEIGHT, CAMSPEED)

	position.x = camera_room_position.x*ROOM_WIDTH
	position.y = camera_room_position.y*ROOM_HEIGHT

	if previous_position != position:
		var direction_x = clampi(previous_position.x - position.x,-1,1)
		var direction_y = clampi(previous_position.y - position.y,-1,1)
		
		direction = Vector2(direction_x,direction_y)
		transition_time.start()
		player.lockout = true
	
	

func _on_transition_time_timeout():
	player.lockout = false
