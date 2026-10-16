extends Control

@export_category("Equipment Slot Settings")
@export var icon: Texture2D

func _ready() -> void:
	get_node("Icon").set_texture(icon)

func set_icon(_icon: Texture2D) -> void:
	icon = _icon
	get_node("Icon").set_texture(icon)
	
