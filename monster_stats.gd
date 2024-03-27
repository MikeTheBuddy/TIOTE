extends Resource

class_name MonsterStats

@export_category("Basic Stats")
@export var health: int
@export var defense: int
@export var attack: int

@export_category("Sprites")
@export var sprite: Texture2D
@export var idle_animation: Animation
@export var chase_animation: Animation
@export var death_animation: Animation
@export var attack_animation: Animation

