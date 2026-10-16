extends Node2D

enum BuildingType {
	MUSHROOM,
	MONASTERY,
}

@export_category("Popup Menu Settings")
@export var dismiss_after_click: bool = true
@export var type: BuildingType = BuildingType.MUSHROOM
@export var player_distance: int = -1

@export_category("Popup Menu List")
@export var row_1_col_1a: String
@export var row_1_col_1b: Texture2D
@export var row_1_col_2a: String
@export var row_1_col_2b: Texture2D
@export var row_1_col_3a: String
@export var row_1_col_3b: Texture2D

@export var row_2_col_1a: String
@export var row_2_col_1b: Texture2D
@export var row_2_col_2a: String
@export var row_2_col_2b: Texture2D
@export var row_2_col_3a: String
@export var row_2_col_3b: Texture2D

@export var row_3_col_1a: String
@export var row_3_col_1b: Texture2D
@export var row_3_col_2a: String
@export var row_3_col_2b: Texture2D
@export var row_3_col_3a: String
@export var row_3_col_3b: Texture2D

@export_category("Icon Texture")
@export var icon: Texture2D
@export var h_v_frames: Vector2 = Vector2(1, 1)
@export var frame: int = 0
@export_category("Icon Tansform")
@export var icon_position: Vector2 = Vector2(0.0, 0.0)
@export var icon_scale: Vector2 = Vector2(1.0, 1.0)

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
var within_range: bool = false

func _ready() -> void:
	var popup_menu = get_node("PopupMenu")
	if popup_menu != null:
		popup_menu.update_menu(row_1_col_1a, row_1_col_1b, row_1_col_2a, row_1_col_2b, row_1_col_3a, row_1_col_3b, \
			row_2_col_1a, row_2_col_1b, row_2_col_2a, row_2_col_2b, row_2_col_3a, row_2_col_3b, \
			row_3_col_1a, row_3_col_1b, row_3_col_2a, row_3_col_2b, row_3_col_3a, row_3_col_3b)
		popup_menu.dismiss_after_click = dismiss_after_click
		popup_menu.player_distance = player_distance
	
	var small_sign = get_node("SmallSign")
	if small_sign != null:
		small_sign.icon = icon
		small_sign.h_v_frames = h_v_frames
		small_sign.frame = frame
		small_sign.icon_position = icon_position
		small_sign.icon_scale = icon_scale


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		within_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		within_range = false


func get_popup_data(index: int) -> Dictionary:
	var result = {}
	if type == BuildingType.MUSHROOM:
		result = {"need": {"from": "player","where": "inventory","what": "mushroom","amount": index},
			"give": {"what": "coin","where": "inventory","amount": index}
		}
	elif type == BuildingType.MONASTERY:
		result = {"need": {"from": "player","where": "inventory","what": "coin","amount": index},
			"give": {"what": "hp","where": "stats","amount": (index * 10)}
		}
	return result
