extends Resource

class_name TeleportInformation

@export_category("Teleport Information")

@export_subgroup("Texture of Teleport Object When Away")
@export var teleport_texture_away : Texture2D

@export_subgroup("Texture of Teleport Object When Close")
@export var teleport_texture_close : Texture2D

@export_subgroup("Scene To Teleport")
@export var teleport_scene : String

@export_subgroup("Position To Teleport")
@export var teleport_position : Vector2
