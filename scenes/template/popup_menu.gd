extends Control

@export_category("Settings")
@export var dismiss_after_click: bool = true
@export var player_distance: float = -1.0

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	pass


func update_menu(	row_1_col_1a: String, row_1_col_1b: Texture2D,
					row_1_col_2a: String, row_1_col_2b: Texture2D,
					row_1_col_3a: String, row_1_col_3b: Texture2D,
					row_2_col_1a: String, row_2_col_1b: Texture2D,
					row_2_col_2a: String, row_2_col_2b: Texture2D,
					row_2_col_3a: String, row_2_col_3b: Texture2D,
					row_3_col_1a: String, row_3_col_1b: Texture2D,
					row_3_col_2a: String, row_3_col_2b: Texture2D,
					row_3_col_3a: String, row_3_col_3b: Texture2D
	) -> void:
	for i in 3:
		for j in 3:
			clear_cell(str(i + 1), str(j + 1))
	
	var rows_set = 1
	if (row_2_col_1a != "" or row_2_col_1b != null) and (row_2_col_2a != "" or row_2_col_2b != null) \
		and (row_2_col_3a != "" or row_2_col_3b != null):
			rows_set += 1
	if (row_3_col_1a != "" or row_3_col_1b != null) and (row_3_col_2a != "" or row_3_col_2b != null) \
		and (row_3_col_3a != "" or row_3_col_3b != null):
			rows_set += 1
	if rows_set != 3:
		get_node("VBG/HBG2").set_visible(false)
		get_node("VContentSelect/Row2").set_visible(false)
		get_node("VContent/Row2").set_visible(false)
	else:
		get_node("VBG/HBG2").set_visible(true)
		get_node("VContentSelect/Row2").set_visible(true)
		get_node("VContent/Row2").set_visible(true)
	# row 1
	set_cell("1", "1", row_1_col_1a, row_1_col_1b)
	set_cell("1", "2", row_1_col_2a, row_1_col_2b)
	set_cell("1", "3", row_1_col_3a, row_1_col_3b)
	# row 2
	if rows_set > 1:
		var row = 2
		if rows_set != 3:
			row = 3
		set_cell(str(row), "1", row_2_col_1a, row_2_col_1b)
		set_cell(str(row), "2", row_2_col_2a, row_2_col_2b)
		set_cell(str(row), "3", row_2_col_3a, row_2_col_3b)
		# row 2
		if rows_set == 3:
			set_cell("3", "1", row_3_col_1a, row_3_col_1b)
			set_cell("3", "2", row_3_col_2a, row_3_col_2b)
			set_cell("3", "3", row_3_col_3a, row_3_col_3b)


func set_cell(row: String, col: String, a: String, b: Texture2D) -> void:
	if a != "":
		get_node("VContent/Row" + row + "/Col" + col + "a").set_text(a)
		get_node("VContent/Row" + row + "/Col" + col + "a").set_visible(true)
		get_node("VContent/Row" + row + "/Col" + col + "b").set_visible(false)
	elif b != null:
		get_node("VContent/Row" + row + "/Col" + col + "b").set_texture(b)
		get_node("VContent/Row" + row + "/Col" + col + "b").set_visible(true)
		get_node("VContent/Row" + row + "/Col" + col + "a").set_visible(false)
	else:
		get_node("VContent/Row" + row + "/Col" + col + "b").set_visible(false)
		get_node("VContent/Row" + row + "/Col" + col + "a").set_visible(false)


func clear_cell(row: String, col: String) -> void:
	get_node("VContent/Row" + row + "/Col" + col + "a").set_text("")
	get_node("VContent/Row" + row + "/Col" + col + "a").set_visible(false)
	get_node("VContent/Row" + row + "/Col" + col + "b").set_texture(null)
	get_node("VContent/Row" + row + "/Col" + col + "b").set_visible(false)


func _on_row_1_mouse_entered() -> void:
	get_node("VContentSelect/Row1/Col1").set_visible(true)


func _on_row_1_mouse_exited() -> void:
	get_node("VContentSelect/Row1/Col1").set_visible(false)


func _on_row_2_mouse_entered() -> void:
	get_node("VContentSelect/Row2/Col1").set_visible(true)


func _on_row_2_mouse_exited() -> void:
	get_node("VContentSelect/Row2/Col1").set_visible(false)


func _on_row_3_mouse_entered() -> void:
	get_node("VContentSelect/Row3/Col1").set_visible(true)


func _on_row_3_mouse_exited() -> void:
	get_node("VContentSelect/Row3/Col1").set_visible(false)


func _on_row_1_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if player_distance < 0.0 or distance_to_player() <= player_distance:
			print("TODO: Event: ", event)
			GameData.popup_menu_selected.emit(get_parent(), 1)
			get_node("VContent/Row1").accept_event()
			if dismiss_after_click:
				set_visible(false)
		else:
			print("TODO: Popup cater for click but player is too far")


func distance_to_player() -> float:
	return global_position.distance_to(player.global_position)
