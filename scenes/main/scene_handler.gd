extends Node

@export var main_menu_packed: PackedScene
@export var game_scene_packed: PackedScene

enum TestEnum {
	FIRST_NUME,
	SECOND_ENUM
}

func _ready() -> void:	
	#print("Enum keys(): ", TestEnum.keys())
	#print("Enum keys().get(TestEnum.SECOND_ENUM): ", TestEnum.keys().get(TestEnum.SECOND_ENUM))
	#print("Enum keys().find(\"SECOND_ENUM\"): ", TestEnum.keys().find("SECOND_ENUM"))
	#TranslationServer.set_locale("es")
	#print(TranslationServer.get_locale())
	#print(tr("ui.new_game"))
	load_main_menu("game_start")


func load_main_menu(_origin: String) -> void:
	if _origin == "end_game_screen":
		get_node("GameScene").queue_free()
	var main_menu: Control = main_menu_packed.instantiate()
	main_menu.new_game_pressed.connect(new_game)
	main_menu.load_game_pressed.connect(load_game)
	main_menu.save_game_pressed.connect(save_game)
	main_menu.settings_pressed.connect(settings_open)
	main_menu.about_pressed.connect(about_open)
	main_menu.exit_pressed.connect(exit_game)
	add_child(main_menu)


func new_game(_origin: String) -> void:
	if _origin == "main_menu":
		get_node("MainMenu").queue_free()
	if _origin == "end_game_screen":
		get_node("GameScene").queue_free()
		await get_tree().process_frame
	var game_scene = game_scene_packed.instantiate()
	add_child(game_scene)


func load_game(_origin: String) -> void:
	pass


func save_game(_origin: String) -> void:
	pass


func settings_open(_origin: String) -> void:
	pass


func about_open(_origin: String) -> void:
	pass


func exit_game(_origin: String) -> void:
	get_tree().quit()
	
