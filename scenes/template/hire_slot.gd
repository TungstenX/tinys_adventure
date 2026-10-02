extends Control

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

var selected: bool = false
#TODO: Do this better, maybe a pointer to this?
var npc: Node2D

func set_avatar(face_icon: Texture2D) -> void:
	get_node("BG/Avatar").set_texture(face_icon)


func set_selected(_selected: bool) -> void:
	selected = _selected
	if selected:
		get_node("BG").modulate = Color("80ff00")
	else:
		get_node("BG").modulate = Color.WHITE


func is_selected() -> bool:
	return selected


func _on_avatar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		player.change_hire_selection(self) # Replace with function body.
