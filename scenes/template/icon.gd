extends TextureRect

@onready var split_popup: PackedScene = preload("res://scenes/template/split_popup.tscn")
@onready var stats_popup: PackedScene = preload("res://scenes/template/stats_popup.tscn")

var message: String

func _ready() -> void:
	create_inventory_info()
	GameData.inventory_changed.connect(create_inventory_info)


func _get_drag_data(_at_position: Vector2) -> Variant:
	var inventory_slot_name: String = get_parent().get_name()
	# InventorySlotUI1
	# 0123456789012
	var inventory_slot_index: int = int(inventory_slot_name.substr(15))
	if PlayerData.has_inventory_item(inventory_slot_index):
		var panel = "Inventory"
		if get_node("../../../../../../").get_name() == "InventoryOther":
			panel = "OtherInventory"
		var data = {}
		var inventory_item = PlayerData.get_inventory_item(inventory_slot_index)
		data.set("origin_node", self)
		data.set("origin_panel", panel)
		data.set("origin_inventory_item", inventory_item)
		data.set("origin_inventory_index", inventory_slot_index)
		
		var item_template = GameData.get_item_template(inventory_item.get("template_id"))
		if item_template.has("EQUIPMENT") and item_template.get("EQUIPMENT") != null and \
			item_template.get("EQUIPMENT").has("SLOT"):
			data.set("origin_equipment_slot", item_template.get("EQUIPMENT").get("SLOT"))
		else:
			data.set("origin_equipment_slot", null)
		
		data.set("origin_texture", texture)
		
		play_sfx(item_template, "_grab")
		
		var drag_texture = TextureRect.new()
		drag_texture.texture = texture
		drag_texture.size = Vector2(64, 64)
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.position = -0.5 * drag_texture.size
		set_drag_preview(control)
		GlobalData.character_sheet_busy_dragging = true
		return data
	GlobalData.character_sheet_busy_dragging = false
	return null


func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	var cursor_yes = load("res://assets/ui/pointers/Cursor_02.png")
	var cursor_no = load("res://assets/ui/pointers/Cursor_03.png")
	var target_inventory_slot = get_parent().get_name()
	var inventory_item = null
	var inventory_slot_index
	if _data.get("origin_panel") == "Inventory" or _data.get("origin_panel") == "Equipment":
		inventory_slot_index = int(target_inventory_slot.substr(15))
		if inventory_slot_index == _data.get("origin_inventory_index"):
			Input.set_custom_mouse_cursor(cursor_yes)
			return false
		if PlayerData.has_inventory_item(inventory_slot_index):
			inventory_item = PlayerData.get_inventory_item(inventory_slot_index)
	 
	if inventory_item == null or inventory_item.get("template_id") == null:
		_data.set("target_inventory_index", inventory_slot_index)
		_data.set("target_inventory_item", null)
		_data.set("target_texture", null)
		if _data.get("origin_panel") == "Equipment":
			Input.set_custom_mouse_cursor(cursor_no)
			return false
		else:
			Input.set_custom_mouse_cursor(cursor_yes)
			return true
	else:
		if Input.is_action_pressed("shifty"):
			Input.set_custom_mouse_cursor(cursor_no)
			return false
		else:
			var item = GameData.get_item_template(inventory_item.get("template_id"))
			if not item.get("INVENTORY").get("STACKABLE") and _data.get("origin_panel") != "Equipment":
				Input.set_custom_mouse_cursor(cursor_no)
				return false
			if _data.get("origin_panel") == "Equipment":
				# can we swap it?
				#print(inventory_item)
				var target_template = GameData.get_item_template(inventory_item.get("template_id"))
				var origin_slot = _data.get("origin_equipment_slot")
				if target_template != null and target_template.has("EQUIPMENT") and target_template.get("EQUIPMENT") != null:
					_data.set("target_inventory_index", inventory_slot_index)
					_data.set("target_inventory_item", inventory_item)
					_data.set("target_texture", texture)
					var result = target_template.get("EQUIPMENT").get("SLOT") == origin_slot.to_upper()
					if result:
						Input.set_custom_mouse_cursor(cursor_yes)
					else:
						Input.set_custom_mouse_cursor(cursor_no)
					return result
				Input.set_custom_mouse_cursor(cursor_no)
				return false
			else:
				var total_stack_after_drop = _data["origin_inventory_item"].get("instance_ids").size() + \
					inventory_item.get("instance_ids").size()
				if total_stack_after_drop > item.get("INVENTORY").get("MAX_STACK_SIZE"):
					Input.set_custom_mouse_cursor(cursor_no)
					return false
				_data.set("target_inventory_index", inventory_slot_index)
				_data.set("target_inventory_item", inventory_item)
				_data.set("target_texture", texture)
				_data.set("target_stack", inventory_item.get("instance_ids").size())
				if _data.get("target_stack") == null or _data.get("target_stack") == 0:
					_data.set("target_stack", 1)
				if _data.get("origin_panel") == "Equipment":
					if not item.has("Equipment"):
						Input.set_custom_mouse_cursor(cursor_no)
						return false
					var target_equipment_slot = item.get("Equipment").get("Slot")
					if target_equipment_slot != _data.get("origin_equipment_slot"):
						Input.set_custom_mouse_cursor(cursor_no)
					else:					
						Input.set_custom_mouse_cursor(cursor_yes)
					return target_equipment_slot == _data.get("origin_equipment_slot")
				else:
					Input.set_custom_mouse_cursor(cursor_yes)
					return true


func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	var cursor = load("res://assets/ui/pointers/01.png")
	Input.set_custom_mouse_cursor(cursor)
	
	GlobalData.character_sheet_busy_dragging = false
	
	var original_inventory_item = _data.get("origin_inventory_item")
	var item_template = GameData.get_item_template(original_inventory_item.get("template_id"))
	play_sfx(item_template, "_drop")
		
	if _data.get("origin_node") == self:
		pass
	elif Input.is_action_pressed("shifty") and \
		(_data.get("origin_panel") == "Inventory" or _data.get("origin_panel") == "OtherInventory") and \
		original_inventory_item.get("instance_ids").size() > 1:
		#TODO: The split dlg
		var split_popup_instance = split_popup.instantiate()
		split_popup_instance.position = get_parent().get_global_transform_with_canvas().origin + Vector2(0, 64)
		split_popup_instance.data = _data
		add_child(split_popup_instance)
		get_node("SplitPopup").set_visible(true)
	else:
		# Move the item data
		if _data.get("origin_panel") == "Inventory":
			# origin item id = target item id and stackable
			if _data.get("target_inventory_item") != null and \
				_data.get("target_inventory_item").get("id") == _data.get("origin_inventory_item").get("id") and \
				item_template.get("INVENTORY").get("STACKABLE") == true:
				#TODO: Create intance count in player data
				var amount = PlayerData.count_inventory_instance_item(_data.get("origin_inventory_index"))
				var instance_ids: Array = PlayerData.destack_inventory_item(_data.get("origin_inventory_index"), amount)
				while not instance_ids.is_empty():
					var id = instance_ids.pop_front()
					var added = PlayerData.set_inventory_item(_data.get("target_inventory_index"), id)
					if not added:
						if not PlayerData.set_inventory_item(_data.get("origin_inventory_index"), id):
							#TODO: Report debug error
							pass
						break # out of loop
				while not instance_ids.is_empty():
					var id = instance_ids.pop_front()
					if not PlayerData.set_inventory_item(_data.get("origin_inventory_index"), id):
						#TODO: Report debug error
						pass
			else:
				PlayerData.swap_inventory_item(_data.get("origin_inventory_index"), _data.get("target_inventory_index"))
		elif _data.get("origin_panel") == "Equipment":
			#Equipment is never stackable
			var origin_item_instance = _data.get("origin_inventory_item")
			var target_item_instance = _data.get("target_inventory_item")
			if target_item_instance == null:
				#no swap, just add
				PlayerData.set_equipment_data(_data.get("origin_equipment_slot"), null)
				PlayerData.set_inventory_item(_data.get("target_inventory_index"), origin_item_instance.get("id"))
			else:
				# can swap
				var current_inventory_instance_id = PlayerData.remove_instance_from_inventory_item(_data.get("target_inventory_index"))				
				PlayerData.set_equipment_data(_data.get("origin_equipment_slot"), current_inventory_instance_id)
				PlayerData.set_inventory_item(_data.get("target_inventory_index"), origin_item_instance.get("id"))
				print(PlayerData.get_inventory_item(_data.get("target_inventory_index")))
			GameData.equipment_changed.emit()
		GameData.inventory_changed.emit()


#TODO: Buffs and debuffs
func _on_mouse_entered() -> void:
	if texture == null or GlobalData.character_sheet_busy_dragging:
		return
		
	get_node("../NinePatchRect").set("modulate", Color("80ff00"))
	
	if message != null:
		for node in get_tree().get_nodes_in_group("stats_popup"):
			node.queue_free()
		var stats = stats_popup.instantiate()
		stats.text = message
		stats.position = get_parent().get_global_transform_with_canvas().origin + Vector2(0, 64)
		stats.add_to_group("stats_popup")
		add_child(stats)
		get_node("StatsPopup").set_visible(true)


func create_inventory_info() -> void:
	var correct_page: bool = get_node("../../../../../../../BookPageEquipment").is_visible()
	
	var slot_name = get_parent().get_name()
	var slot_index = int(slot_name.substr(15))
	if PlayerData.has_inventory_item(slot_index):
		var current_item_instance = PlayerData.get_inventory_item(slot_index)
		var template = GameData.get_item_template(current_item_instance.get("template_id"))
		
		message = "[outline_size=2][font_size=26]" + tr(template.get("NAME")) + "[/font_size][/outline_size]\n" + \
		"[p]" + tr(template.get("DESCRIPTION")) + "[/p]\n[hr]\n"
		var stats_ind: int = 0
		if template.has("EQUIPMENT") and template.get("EQUIPMENT") != null:
			for i in GameData.STATS.size():
				var stat_name = GameData.STATS[i]
				var stat_value: float = 0.0
				if template.get("EQUIPMENT").has(stat_name) and template.get("EQUIPMENT").get(stat_name) != null:
					stat_value = template.get("EQUIPMENT").get(stat_name)
				message += tr("ui.equipment.stat." + stat_name.to_lower()).to_upper() + ": " + str(template.get("EQUIPMENT").get(stat_name)) + " "
				if correct_page:
					var stat_delta = compare_stat(template, stat_name, stat_value)
					if stat_delta != 0.0:
						var font_colour_start = ""
						var font_colour_end = ""
						if stat_delta > 0.0:
							stats_ind += 1
							font_colour_start = "[color=#3eff00]"
							font_colour_end = "[/color]"
						elif stat_delta < 0.0:
							stats_ind -= 1
							font_colour_start = "[color=#ff0000]"
							font_colour_end = "[/color]"
						message += "(" + font_colour_start + str(stat_delta) + font_colour_end + ") "
		get_node("../").set_stats_ind(stats_ind)
	else:
		get_node("../").set_stats_ind(0)


#TODO: Buffs and debuffs
func compare_stat(template: Dictionary, stat_name: String, stat_value: float) -> float:
	var stat_difference: float
	var equipment_slot = template.get("EQUIPMENT").get("SLOT").to_lower()
	if PlayerData.has_equipment_data(equipment_slot):
		var current_item_instance_id = PlayerData.get_equipment_data(equipment_slot)
		var template_id = GameInstanceData.get_item_instance(current_item_instance_id).get("template_id")
		var equipment_template = GameData.get_item_template(template_id)
		var current_stat_value: float = equipment_template.get("EQUIPMENT").get(stat_name)
		if current_stat_value == null:
			current_stat_value = 0.0
		stat_difference = stat_value - current_stat_value
	else:
		stat_difference = stat_value
	return stat_difference


func _on_mouse_exited() -> void:
	get_node("../NinePatchRect").set("modulate", Color.WHITE)
	if GlobalData.character_sheet_busy_dragging:
		return
	#var stats = get_node("StatsPopup")
	#if stats != null:
		#stats.queue_free()


func split_stack(_split_amount: int, _data):
	var target_inventory_slot = get_parent().get_name()
	
	#var new_stack_amount = _data["origin_stack"] - _split_amount
	if _data.get("origin_panel") == "Inventory":
		var target_stack = PlayerData.destack_inventory_item(_data.get("origin_inventory_index"), _split_amount)
		# add to new stack
		var inventory_slot_index: int = int(target_inventory_slot.substr(15))
		while not target_stack.is_empty():
			var instance_id: String = target_stack.pop_front()
			var added = PlayerData.set_inventory_item(inventory_slot_index, instance_id)
			if not added:
				target_stack.append(instance_id)
				break # out of loop
		# return what was left
		while not target_stack.is_empty():
			var instance_id: String = target_stack.pop_front()
			var added = PlayerData.set_inventory_item(_data.get("origin_inventory_index"), instance_id)
			if not added:
				#TODO: Report debug error
				pass
		GameData.inventory_changed.emit()


func play_sfx(item_template: Dictionary, what:String) -> void:
		#Sound FX
	var sfx_sound = "default"
	if item_template.has("Sfx"):
		sfx_sound = item_template.get("Sfx")
	var sfx_file = load("res://Sfx/" + sfx_sound + what + ".wav")
	get_node("/root/SceneHandler/UISFX").set_stream(sfx_file)
	get_node("/root/SceneHandler/UISFX").play()


func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		if not is_drag_successful() and not Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
			_on_drop_failed()

func _on_drop_failed():
	if GlobalData.character_sheet_busy_dragging:
		GlobalData.character_sheet_busy_dragging = false
		print("The item was dropped somewhere invalid")
		var cursor = load("res://assets/ui/pointers/01.png")
		Input.set_custom_mouse_cursor(cursor)
