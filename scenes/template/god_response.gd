extends Control

enum Entity{
	GOD,
	DEVIL
}
@export_category("Entity")
@export var which: Entity = Entity.GOD

func _ready() -> void:
	if which == Entity.DEVIL:
		get_node("Label").set("theme_override_colors/font_color", Color("ff0000"))
