extends Node

var player_data


func _ready():
	load_user_player_data()


func load_user_player_data():
	if FileAccess.file_exists("user://PlayerData.json"):
		var player_data_file = FileAccess.open("user://PlayerData.json", FileAccess.READ)
		player_data = JSON.parse_string(player_data_file.get_as_text())
		player_data_file.close()
	else:
		load_first_player_data()
	#process_loaded_buffs()


func load_first_player_data() -> void:
	var player_data_file = FileAccess.open("res://data/PlayerDataFirst.json", FileAccess.READ)
	player_data = JSON.parse_string(player_data_file.get_as_text())
	player_data_file.close()
	save_user_player_data()


func save_user_player_data():
	var file = FileAccess.open("user://PlayerData.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(player_data, "\t"))
	file.close()


func get_player_level() -> int:
	return player_data.get("player_level")


func set_player_level(new_level: int):
	player_data.set("player_level", new_level)


func inc_player_level(amount: int = 1) -> int:
	player_data.set("player_level", get_player_level() + amount)
	return get_player_level()


func get_player_experiece() -> int:
	return player_data.get("player_experience")


func set_player_experiece(new_experiece: int):
	player_data.set("player_experiece", new_experiece)


func inc_player_experiece(amount: int = 1) -> int:
	player_data.set("player_experiece", get_player_experiece() + amount)
	return get_player_experiece()


func get_current_hp() -> float:
	return player_data.get("current_derived").get("hp")


func set_current_hp(new_value: float):
	player_data.get("current_derived").set("hp", new_value)


func inc_current_hp(amount: float) -> float:
	player_data.get("current_derived").set("hp", get_current_hp() + amount)
	return get_current_hp()

func dec_current_hp(amount: float) -> float:
	return inc_current_hp(amount * -1)

func get_current_speed() -> float:
	return player_data.get("current_derived").get("spd")


func set_current_speed(new_value: float):
	player_data.get("current_derived").set("spd", new_value)


func inc_current_speed(amount: float) -> float:
	player_data.get("current_derived").set("spd", get_current_speed() + amount)
	return get_current_speed()


func get_current_attack() -> float:
	return player_data.get("current_derived").get("atk")


func set_current_attack(new_value: float):
	player_data.get("current_derived").set("atk", new_value)


func inc_current_attack(amount: float) -> float:
	player_data.get("current_derived").set("atk", get_current_attack() + amount)
	return get_current_attack()


func get_max_hp() -> float:
	# do the buff stuff here
	return GameData.get_max_per_level("HP", get_player_level())


func get_max_speed() -> float:
	# do the buff stuff here
	return GameData.get_max_per_level("SPD", get_player_level())


func add_to_inventory(_amount: int, _type: GameData.InventoryType) -> int:
	for i in player_data.get("inventory"):
		if i.get("id") == int(_type):
			var amount = _amount
			if i.get("amount")  + _amount > i.get("max"):
				amount = max - i.get("amount")
			if amount <= 0:
				return 0
			else:
				i.set("amount", i.get("amount")  + amount)
				return amount
	return 0


func remove_from_inventory(_amount: int, _type: GameData.InventoryType) -> int:
	for i in player_data.get("inventory"):
		if i.get("id") == int(_type):
			var amount = _amount
			if i.get("amount")  - _amount < 0:
				amount = i.get("amount")
			if amount <= 0:
				return 0
			else:
				i.set("amount", i.get("amount")  - amount)
				return amount
	return 0


func get_inventory_amount(_type: GameData.InventoryType) -> int:
	for i in player_data.get("inventory"):
		if i.get("id") == int(_type):
			return i.get("amount")
	return 0

#TODO: Change to calculated values
func get_derived_stat(name: String) -> float:
	return player_data.get("current_derived").get(name)
