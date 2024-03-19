extends Node2D

@onready var day_cycle = $DayCycle

@export var gradient:GradientTexture1D

const TIMER_DAY = 60
	
func _process(_delta):
	var value = (sin(Globaltime.timer/TIMER_DAY - PI / 2.0) + 1.0) / 2.0
	day_cycle.color = gradient.gradient.sample(value)
