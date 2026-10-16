extends Node

var player_data


func _ready():
	load_user_player_data()

#┌───────────────────────┐
#│ Load and save of data │
#└───────────────────────┘
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


#┌───────────────────┐
#│ Player properties │
#└───────────────────┘
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


#┌───────────────┐
#│ Derived stats │
#└───────────────┘
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


#┌───────────┐
#│ Inventory │
#└───────────┘
func already_in_inventory(_template_id: String, _instance_id: String, _slot_number: int) -> bool:
	if _slot_number == -1:
		for slot_key in player_data.get("inventory"):
			var slot = player_data.get("inventory").get(slot_key)
			if slot.get("template_id") == _template_id:
				for instance_id in slot.get("instance_ids"):
					if instance_id == _instance_id:
						return true
	else:
		var slot = player_data.get("inventory").get(_slot_number)
		if slot.get("template_id") == _template_id:
			for instance_id: String in slot.get("instance_ids"):
					if instance_id == _instance_id:
						return true
	return false


func add_to_inventory(_template_id: String, _instance_id: String = "", _slot_number: int = -1) -> int:
	var instance = null
	var template = GameData.get_item_template(_template_id)
	if _instance_id == "":
		# create new instance
		instance = {
			"id": UUID.v4(),
			"template_id": _template_id
		}
		GameInstanceData.add_item_instance(instance)
		_instance_id = instance.get("id")
	else:
		#fetch instance
		pass
		
	if already_in_inventory(_template_id, _instance_id, _slot_number):
		return 0
		
	# If stackable find first availble slot to stack
	var added = false
	if template.get("INVENTORY").get("STACKABLE"):
		var max_stackable = template.get("INVENTORY").get("MAX_STACK_SIZE")
		for slot_key in player_data.get("inventory"):
			var slot = player_data.get("inventory").get(slot_key)
			if slot != null and slot.get("template_id") == _template_id:
				# found a slot that contain the same template id/same type
				var stack_count = slot.get("instance_ids").size()
				if stack_count >= max_stackable:
					continue
				else:
					slot.get("instance_ids").append(_instance_id)
					added = true
					break # out of loop
	else:
		for i in player_data.get("inventory_capacity").get("number_of_slots"):
			var slot_number = i + 1
			var slot_name = "slot" + str(slot_number)
			if not player_data.get("inventory").has(slot_name):
				#first open one
				var slot_data = {
					"instance_ids": [_instance_id],
					"template_id": _template_id
				}
				player_data.get("inventory").set(slot_name, slot_data)
				added = true
				break # out of loop
				
	if not added and player_data.get("inventory").size() < player_data.get("inventory_capacity").get("number_of_slots"):
		var slot_name = "slot" + player_data.get("inventory").size()
		var slot_data = {
			"instance_ids": [_instance_id],
			"template_id": _template_id
		}
		player_data.get("inventory").set(slot_name, slot_data)
		added = true
	if added:
		return 1
	else:
		return -1


func set_inventory_item(_slot_number: int, _instance_id: String) -> bool:
	var new_item_instance = GameInstanceData.get_item_instance(_instance_id)
	if new_item_instance == null:
		return false
	var new_template_item = GameData.get_item_template(new_item_instance.get("template_id"))
	if new_template_item == null:
		return false

	var current_item_instance = get_inventory_item(_slot_number)
	if current_item_instance != null:
		var current_template = GameData.get_item_template(current_item_instance.get("template_id"))
		if current_template != null:
			if new_template_item.get("ID") == current_template.get("ID") and \
			new_template_item.get("INVENTORY").get("STACKABLE"):
				#check size
				if current_item_instance.get("instance_ids").size() < new_template_item.get("INVENTORY").get("MAX_STACK_SIZE"):
					current_item_instance.get("instance_ids").append(_instance_id)
					return true
			return false
	# No current item, just set
	#create new player inventory item
	var inventory_item = {
		"instance_ids" = [new_item_instance.get("id")],
		"template_id" = new_item_instance.get("template_id")
	}
	player_data.get("inventory").set("slot" + str(_slot_number), inventory_item)
	return true


func remove_from_inventory(_amount: int, _template_id: String) -> Dictionary:
	var result = {
		"remaining": _amount,
		"instance_ids": []
	}
	var to_be_removed = []
	var count = _amount
	for slot_key in player_data.get("inventory"):
		var slot = player_data.get("inventory").get(slot_key)
		if _template_id == slot.get("template_id"):
			var loop = count > 0
			while loop:
				var instance_id = slot.get("instance_ids").pop_front()
				if instance_id != null:
					result.get("instance_ids").append(instance_id)
					count -= 1
					loop = count > 0
				else:
					to_be_removed.append(slot_key)
					loop = false
	for key in to_be_removed:
		if not player_data.get("inventory").erase(key):
			print("Could not erase from player inventory key: ", key)
			
	result.set("remaining", count)
	return result


func remove_instance_from_inventory_item(_index: int) -> Variant:
	if player_data.get("inventory").has("slot" + str(_index)):
		var ids = player_data.get("inventory").get("slot" + str(_index)).get("instance_ids")
		var id = ids.pop_front()
		if ids.is_empty():
			#remove slot completely
			player_data.get("inventory").erase("slot" + str(_index))
		return id
	return null


func swap_inventory_item(_index_origin: int, _index_target: int) -> void:
	var target_value = null
	var origin_value = player_data.get("inventory").get("slot" + str(_index_origin))
	if player_data.get("inventory").has("slot" + str(_index_target)) and \
		player_data.get("inventory").get("slot" + str(_index_target)) != null:
		target_value = player_data.get("inventory").get("slot" + str(_index_target))
	
	player_data.get("inventory").set("slot" + str(_index_target), origin_value)
	if target_value == null:
		player_data.get("inventory").erase("slot" + str(_index_origin))
	else:
		player_data.get("inventory").set("slot" + str(_index_origin), target_value)


func get_inventory_amount(_template_id: String) -> int:
	var count = 0
	for slot_key in player_data.get("inventory"):
		var slot = player_data.get("inventory").get(slot_key)
		if _template_id == slot.get("template_id"):
			count += slot.get("instance_ids").size()
	return count


#TODO: Change to calculated values
func get_derived_stat(_name: String) -> float:
	return player_data.get("current_derived").get(_name)


func get_inventory_item(_slot:  Variant) -> Variant:
	if player_data.get("inventory").has("slot" + str(_slot)):
		return player_data.get("inventory").get("slot" + str(_slot))
	return null


func add_coins(_amount: int) -> void:
	player_data.set("coins", player_data.get("coins") + _amount)


func get_coins() -> int:
	return player_data.get("coins")


func remove_coins(_amount: int) -> void:
	player_data.set("coins", player_data.get("coins") - _amount)


func get_inventory_capacity_number_of_slots() -> int:
	return player_data.get("inventory_capacity").get("number_of_slots")


#TODO: add to json
func add_trophy(trophy_name: String, enemy: bool) -> bool:
	var result = false
	if not player_data.has("trophies"):
		var trophies = {}
		player_data.set("trophies", trophies)
	if not player_data.get("trophies").has(trophy_name):
		var trophy = {
			"name": trophy_name,
			"enemy": enemy,
			"amount": 0
		}
		player_data.get("trophies").set(trophy_name, trophy)
		result = true
	player_data.get("trophies").get(trophy_name).set("amount", player_data.get("trophies").get(trophy_name).get("amount") + 1)
	GameData.trophy_changed.emit()
	return result


func get_trophies() -> Dictionary:
	if not player_data.has("trophies"):
		var trophies = {}
		player_data.set("trophies", trophies)
	return player_data.get("trophies")


func has_inventory_item(index: int) -> bool:
	return player_data.get("inventory").has("slot" + str(index)) and player_data.get("inventory").get("slot" + str(index)) != null


func has_equipment_data(slot: String) -> bool:
	return player_data.get("equipment").has(slot) and player_data.get("equipment").get(slot) != null


func get_equipment_data(slot: String) -> Variant:
	if player_data.get("equipment").has(slot):
		return player_data.get("equipment").get(slot)
	return null


func set_equipment_data(slot: String, instance_id: Variant) -> void:
	player_data.get("equipment").set(slot, instance_id)


func count_inventory_instance_item(_slot: int) -> int:
	var item = get_inventory_item(_slot)
	if item == null:
		return 0
	return item.get("instance_ids").size()


func destack_inventory_item(index: int, number_of_items: int) -> Array:
	var result = []
	var current_inventory_item = get_inventory_item(index)
	if current_inventory_item != null:
		for i in number_of_items:
			var item_instance_id = current_inventory_item.get("instance_ids").pop_front()
			if item_instance_id != null:
				result.append(item_instance_id)
		if current_inventory_item.get("instance_ids").is_empty():
			if not player_data.get("inventory").erase("slot" + str(index)):
				print("Could not erase from player inventory key: ", "slot" + str(index))
	return result
