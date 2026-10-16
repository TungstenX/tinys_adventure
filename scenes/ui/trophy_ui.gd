extends Control

@export_category("Trophy UI Settings")
@export var icon: Texture2D
@export var target_position: Vector2
@export var npc_name: String

func _ready() -> void:
	get_node("Icon").set_texture(icon)
