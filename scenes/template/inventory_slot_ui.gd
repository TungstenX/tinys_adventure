extends Control

@export_category("Inventory Settings")
@export var hot_list_number: int = -1

@onready var stats_ind = get_node("StatsInd")

var stats_ind_sign: int

var instance_id: String

func _ready() -> void:
	if hot_list_number > 0:
		get_node("HotListNumber").set_text(str(hot_list_number))
	else:
		get_node("Amount").set_text("")
	set_stats_ind(stats_ind_sign)

func set_amount(_amount: int) -> void:
	if _amount <= 1:
		get_node("Amount").set_text("")
	else:
		get_node("Amount").set_text(str(_amount))


func set_icon(_texture: Texture2D) -> void:
	get_node("Icon").set_texture(_texture)


func set_instance_id(_instance_id: String) -> void:
	instance_id = _instance_id

func set_stats_ind(magnatude: int) -> void:
	stats_ind_sign = magnatude
	if stats_ind == null:
		return
	if magnatude > 0:
		stats_ind.set_text("+")
		stats_ind.set("theme_override_colors/font_color", Color("80ff00"))
	elif magnatude < 0:
		get_node("StatsInd").set_text("-")
		stats_ind.set("theme_override_colors/font_color", Color.RED)
	else:
		stats_ind.set_text("")
