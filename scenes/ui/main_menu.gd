extends Control

signal new_game_pressed(origin: String)
signal load_game_pressed(origin: String)
signal save_game_pressed(origin: String)
signal settings_pressed(origin: String)
signal about_pressed(origin: String)
signal exit_pressed(origin: String)

var cursor_arrow = load("res://assets/ui/pointers/01.png")
var default_control_size: Vector2 = Vector2(1920, 1080)
var vb_default_position: Vector2 = Vector2(508, 54)
var resizeable = true

func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor_arrow)
	_on_resized()


func _on_resized() -> void:
	#print("Default size:  ", default_control_size)
	#print("Viewport size: ", get_viewport().size)
	#print("MainMenu size: ", get_node(".").size)
	
	#var width_factor: float = get_viewport().size.x / default_control_size.x 
	var height_factor: float = get_viewport().size.y / default_control_size.y
	#print("Height %: ", height_factor * 100.0)
	var factor = height_factor
	#if factor > width_factor: # use the smallest factor
		#factor = width_factor
	get_node("VBoxContainer").scale = Vector2(factor, factor)
	get_node("VBoxContainer").position = vb_default_position * factor
	#print("BV size: ",get_node("VBoxContainer").size)
	#print("BV pos:  ",get_node("VBoxContainer").position)


func _on_new_game_pressed() -> void:
	new_game_pressed.emit("main_menu")


func _on_settings_pressed() -> void:
	settings_pressed.emit("main_menu")


func _on_about_pressed() -> void:
	about_pressed.emit("main_menu")


func _on_exit_pressed() -> void:
	exit_pressed.emit("main_menu")


func _on_load_game_pressed() -> void:
	load_game_pressed.emit("main_menu")


func _on_save_game_pressed() -> void:
	save_game_pressed.emit("main_menu")


func move_label_text_v(which: String, down: bool = true) -> void:
	var amount = 8
	if not down:
		amount *= -1
	var element = get_node("VBoxContainer/" +  which + "/Label")
	element.position.y += amount


func _on_new_game_button_down() -> void:
	move_label_text_v("NewGame")


func _on_new_game_button_up() -> void:
	move_label_text_v("NewGame", false)


func _on_load_game_button_down() -> void:
	move_label_text_v("H/LoadGame")


func _on_load_game_button_up() -> void:
	move_label_text_v("H/LoadGame", false)


func _on_save_game_button_down() -> void:
	move_label_text_v("H/SaveGame")


func _on_save_game_button_up() -> void:
	move_label_text_v("H/SaveGame", false)


func _on_settings_button_down() -> void:
	move_label_text_v("Settings")


func _on_settings_button_up() -> void:
	move_label_text_v("Settings", false)


func _on_about_button_down() -> void:
	move_label_text_v("About")


func _on_about_button_up() -> void:
	move_label_text_v("About", false)


func _on_exit_button_down() -> void:
	move_label_text_v("Exit")


func _on_exit_button_up() -> void:
	move_label_text_v("Exit", false)
