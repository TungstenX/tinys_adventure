extends Node2D

signal levelup

@export var end_game_screen_packed: PackedScene

var total_enemies: int
var enemies_killed: int = 0
var trophy_fly_timer: Timer
var current_flying_trophy

@onready var HUD: Control = $UI/HUD
@onready var player: CharacterBody2D
@onready var trophy_packed: PackedScene = load("res://scenes/ui/trophy_ui.tscn")

func _ready() -> void:	
	var enemy_array: Array = get_tree().get_nodes_in_group("enemies")
	total_enemies = enemy_array.size()
	for enemy in enemy_array:
		enemy.died.connect(enemy_died)
	player = get_tree().get_first_node_in_group("player")
	levelup.connect(player.calculate_stats)
	player.game_over.connect(display_end_game_screen)
	player.update_hp_bar.connect(HUD.update_hp_bar)
	GameData.popup_menu_selected.connect(on_popup_menu_selected)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hotlist1"):
		pass
	elif event.is_action_pressed("hotlist2"):
		pass
	elif event.is_action_pressed("hotlist3"):
		pass
	elif event.is_action_pressed("hotlist4"):
		pass
	elif event.is_action_pressed("hotlist5"):
		pass
	elif event.is_action_pressed("hotlist6"):
		pass
	elif event.is_action_pressed("inventory"):
		HUD.toggle_book("inventory")
	elif event.is_action_pressed("equipment"):
		HUD.toggle_book("equipment")
	elif event.is_action_pressed("book"):
		HUD.toggle_book("book")


func on_popup_menu_selected(which: Node2D, index: int) -> void:
	var data = which.get_popup_data(index)
	if data.get("need").get("from") == "player":
		if data.get("need").get("where") == "inventory":
			if player.get_inventory_amount(data.get("need").get("what").to_upper()) >= data.get("need").get("amount"):
				process_popup_menu_selected(which, data)


func process_popup_menu_selected(which: Node2D, data: Dictionary):
	# we have enough
	if data.get("need").get("from") == "player":
		if data.has("give"):
			if data.get("give").get("where") == "inventory":
				player.add_to_inventory(data.get("give").get("amount"), GameData.InventoryType.keys().find(data.get("give").get("what").to_upper()))
			elif data.get("give").get("where") == "stat":
				player.increase_derived(data.get("give").get("what").to_lower(), data.get("give").get("amount"))
			if data.get("need").get("where") == "inventory":
				player.remove_from_inventory(data.get("need").get("amount"), GameData.InventoryType.keys().find(data.get("need").get("what").to_upper()))
		elif data.has("hire"):
			#TODO: can hire (hire slots open)
			var face_icon = which.hire_me(data.get("hire").get("number_of_actions"))
			player.add_selected_npc(which, face_icon)
			player.remove_from_inventory(data.get("need").get("amount"), GameData.InventoryType.keys().find(data.get("need").get("what").to_upper()))


func enemy_died(exp_reward: int, trophy_name: String, coord: Vector2) -> void:
	enemies_killed += 1
	experience_gained(exp_reward)
	add_trophy(trophy_name, coord, true)
	if enemies_killed == total_enemies:
		display_end_game_screen(true)


func add_trophy(trophy_name: String, _coord: Vector2, enemy: bool) -> void:
	if PlayerData.add_trophy(trophy_name, enemy):
		var icon: Texture2D = load("res://assets/ui/avatars/" + trophy_name + "_Avatar.png")
		current_flying_trophy = trophy_packed.instantiate()
		current_flying_trophy.icon = icon
		var new_pos: Vector2i = (get_viewport().size / 2) + Vector2i(-256, -256)
		current_flying_trophy.set_position(new_pos)
		current_flying_trophy.target_position = Vector2i(0, 0)
		current_flying_trophy.scale = Vector2(0.5, 0.5)
		HUD.add_child(current_flying_trophy)
		if trophy_fly_timer == null:
			trophy_fly_timer = Timer.new()
			add_child(trophy_fly_timer)
			trophy_fly_timer.wait_time = .1
			trophy_fly_timer.timeout.connect(trophy_fly_timeout)
			trophy_fly_timer.start()


func trophy_fly_timeout() -> void:
	if trophy_fly_timer != null:
		if current_flying_trophy.get_position().x > 15.0 and current_flying_trophy.get_position().y > 15.0:
			var x = 0
			var y = 0
			if current_flying_trophy.scale.x < 1.0:
				current_flying_trophy.scale += Vector2(0.01, 0.01)
			if current_flying_trophy.get_position().x < current_flying_trophy.target_position.x:
				x = 10
			elif current_flying_trophy.get_position().x > current_flying_trophy.target_position.x:
				x = -10
			if current_flying_trophy.get_position().y < current_flying_trophy.target_position.y:
				y = 10
			elif current_flying_trophy.get_position().y > current_flying_trophy.target_position.y:
				y = -10
			current_flying_trophy.set_position(current_flying_trophy.get_position() + Vector2(x, y))
		else:
			trophy_fly_timer.stop()
			remove_child(trophy_fly_timer)
			trophy_fly_timer.queue_free()
			HUD.remove_child(current_flying_trophy)
			current_flying_trophy.queue_free()
	
	
func experience_gained(exp_gained: int) -> void:
	if PlayerData.get_player_level() == LevelData.MAX_LEVEL:
		return
	var new_experience: int = PlayerData.get_player_experiece() + exp_gained
	if new_experience >= LevelData.LEVEL_THRESHOLD[PlayerData.get_player_level() - 1]:
		level_up(new_experience)
	else:
		PlayerData.set_player_experiece(new_experience)


func level_up(new_experience: int) -> void:
	print("Level up!")
	new_experience -= LevelData.LEVEL_THRESHOLD[PlayerData.get_player_level() - 1]
	PlayerData.inc_player_level()
	PlayerData.set_player_experiece(new_experience)
	levelup.emit()
	HUD.update_level_indicator()


func display_end_game_screen(victoriuos: bool) -> void:
	var end_game_screen = end_game_screen_packed.instantiate()
	end_game_screen.victoriuos = victoriuos
	
	var scene_handler: Node = get_node("/root/SceneHandler")
	end_game_screen.repeat_level.connect(scene_handler.new_game)
	end_game_screen.main_menu.connect(scene_handler.load_main_menu)
	$UI.add_child(end_game_screen)
	
	await get_tree().create_timer(0.4).timeout
	#var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	player.set_process_mode(PROCESS_MODE_DISABLED)
	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	for i: CharacterBody2D in enemies:
		i.set_process_mode(PROCESS_MODE_DISABLED)
