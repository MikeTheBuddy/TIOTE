extends Node

var timer: float

var seconds: int
var minutes: int


func _ready():
	timer = 0.0

func _process(delta):
	timer += delta
	
	seconds = int(fmod(timer,60))
	
	minutes = int(timer/60)
