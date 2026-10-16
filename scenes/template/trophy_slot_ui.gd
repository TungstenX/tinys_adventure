extends Control

@export_category("Trophy UI Settings")
@export var icon: Texture2D
@export var amount: int = 0
@export var npc_name: String = "Chamán de la" # maldición


func _ready() -> void:
	get_node("Icon").set_texture(icon)
	get_node("Amount").set_text(str(amount))
	get_node("Name").set_text(npc_name)
	var ribbon_text_lines = get_node("Name").get_line_count()
	match ribbon_text_lines:
		1: 
			get_node("Ribbon").size = Vector2(60, 22)
		2: 
			get_node("Ribbon").size = Vector2(60, 36)
		3: 
			get_node("Ribbon").size = Vector2(60, 50)


func set_amount(_amount: int) -> void:
	amount = _amount
	get_node("Amount").set_text(str(amount))
