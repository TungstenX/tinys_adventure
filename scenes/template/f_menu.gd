extends Control

enum FKeysAvailable { F1, F2, F3, F4, F5, F6, F7, F8, F9 }
@export_category("Display Elements")
@export var menu_fn_key: FKeysAvailable
@export var menU_fn_icon: Texture2D
@export var menu_fn_alt_text: String

func _ready() -> void:
	$PanelContainer/NinePatchRect/HBoxContainer/Key.set_text(FKeysAvailable.keys().get(menu_fn_key))
	if menU_fn_icon != null:
		$PanelContainer/NinePatchRect/HBoxContainer/Icon.set_visible(true)
		$PanelContainer/NinePatchRect/HBoxContainer/Icon.set_texture(menU_fn_icon)
		$PanelContainer/NinePatchRect/HBoxContainer/AltText.set_visible(false)
	else:
		$PanelContainer/NinePatchRect/HBoxContainer/AltText.set_visible(true)
		$PanelContainer/NinePatchRect/HBoxContainer/AltText.set_text(menu_fn_alt_text)
		$PanelContainer/NinePatchRect/HBoxContainer/Icon.set_visible(false)
	#var padding := Vector2(110, 64)
	#await get_tree().process_frame
	#$PanelContainer.size = $PanelContainer/NinePatchRect/HBoxContainer/Label.get_minimum_size() + padding
	#size = $PanelContainer.size
