extends Node2D

@onready var day_cycle = $DayCycle
@onready var transition = $GUILayer/Transition/AnimationPlayer

@export var gradient:GradientTexture1D

const TIMER_DAY = 60

func _ready():
	transition.play("fade_in")
	await transition.animation_finished
	Gamestates.in_transition = false

func _process(_delta):
	var value = (sin(Globaltime.timer/TIMER_DAY - PI / 2.0) + 1.0) / 2.0
	day_cycle.color = gradient.gradient.sample(value+0.3)
