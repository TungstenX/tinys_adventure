extends Node2D

@export_category("Texture")
@export var icon: Texture2D
@export var h_v_frames: Vector2 = Vector2(1, 1)
@export var frame: int = 0
@export_category("Tansform")
@export var icon_position: Vector2 = Vector2(0.0, -44.0)
@export var icon_scale: Vector2 = Vector2(1.0, 1.0)


func _ready() -> void:
	get_node("Icon").texture = icon
	get_node("Icon").hframes = h_v_frames.x
	get_node("Icon").vframes = h_v_frames.y
	get_node("Icon").frame = frame
	get_node("Icon").position = icon_position
	get_node("Icon").scale = icon_scale
