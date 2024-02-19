extends CharacterBody2D

var chase = false

var player = null

const SPEED = 10

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $ChaseRadius/CollisionShape2D

func _ready():
	animated_sprite_2d.play("Idle")
	
func _physics_process(delta):
	if chase:
		if player.position.x > position.x:
			animated_sprite_2d.flip_h = false
		else:
			animated_sprite_2d.flip_h = true
		position += (player.position - position).normalized() * SPEED * delta
	#move_and_slide()
	#print(jump_timer)
	
func _on_chase_radius_body_entered(body):
	animated_sprite_2d.play("Jump")
	player = body
	chase = true


func _on_chase_radius_body_exited(_body):
	animated_sprite_2d.play("Idle")
	player = null
	chase = false
