extends TextureRect

@onready var split_popup # = preload("res://scenes/UI/Templates/ItemSplitPopup.tscn")


func _get_drag_data(_at_position: Vector2) -> Variant:
	var equipment_slot = get_parent().get_name().to_lower()
	if PlayerData.has_equipment_data(equipment_slot):
		var data = {}
		var inventory_item_instance_id = PlayerData.get_equipment_data(equipment_slot)
		var inventory_item = GameInstanceData.get_item_instance(inventory_item_instance_id)
		data.set("origin_node", self)
		data.set("origin_panel", "Equipment")
		data.set("origin_inventory_item", inventory_item)
		data.set("origin_equipment_slot", equipment_slot)
		data.set("origin_texture", texture)
		data.set("origin_stackable", false)
		data.set("origin_stack", 1)
		
		
		var item_template = GameData.get_item_template(inventory_item.get("template_id"))
			
		play_sfx(item_template, "_grab")
		
		var drag_texture = TextureRect.new()
		drag_texture.texture = texture
		drag_texture.size = Vector2(64, 64)
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.position = -0.5 * drag_texture.size
		set_drag_preview(control)
		GlobalData.character_sheet_busy_dragging = true
		print("Equipment drag data: ", data)
		return data
	GlobalData.character_sheet_busy_dragging = false
	return null


func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:	
	var cursor_yes = load("res://assets/ui/pointers/Cursor_02.png")
	var cursor_no = load("res://assets/ui/pointers/Cursor_03.png")
	var target_equipment_slot = get_parent().get_name().to_lower()
	if _data.get("origin_equipment_slot") == null:
		Input.set_custom_mouse_cursor(cursor_no)
		return false
	if target_equipment_slot == _data.get("origin_equipment_slot").to_lower():
		if not PlayerData.has_equipment_data(target_equipment_slot):
			#_data.set("target_inventory_index", inventory_slot_index)
			_data.set("target_inventory_item", null)
			_data.set("target_texture", null)
		else:
			var inventory_item = PlayerData.get_equipment_data(target_equipment_slot)
			_data.set("target_inventory_item", inventory_item)
			_data.set("target_texture", texture)
		Input.set_custom_mouse_cursor(cursor_yes)
		return true
	Input.set_custom_mouse_cursor(cursor_no)
	return false
	
func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	var cursor = load("res://assets/ui/pointers/01.png")
	Input.set_custom_mouse_cursor(cursor)	
	GlobalData.character_sheet_busy_dragging = false
	var inv_changed = false
	var target_equipment_slot = get_parent().get_name().to_lower()	
	var original_inventory_item = _data.get("origin_inventory_item")
	var item_template = GameData.get_item_template(original_inventory_item.get("template_id"))
	play_sfx(item_template, "_drop")
		
	if _data.get("origin_node") == self:
		pass
	else:
		# Move the item data
		if _data.get("origin_panel") == "Inventory":
			# origin item id = target item id and stackable
			if _data.get("target_inventory_item") == null:
				var item_instance_id = PlayerData.remove_instance_from_inventory_item(_data.get("origin_inventory_index"))
				PlayerData.set_equipment_data(target_equipment_slot, item_instance_id)
				inv_changed = true
			else:
				var origin_instance_id = PlayerData.remove_instance_from_inventory_item(_data.get("origin_inventory_index"))
				#target_inventory_item 
				PlayerData.set_equipment_data(target_equipment_slot, origin_instance_id)
				PlayerData.set_inventory_item(_data.get("origin_inventory_index"), _data.get("target_inventory_item"))
				inv_changed = true
		elif _data.get("origin_panel") == "Equipment":
			pass # 
		
		if inv_changed:
			GameData.inventory_changed.emit()
			GameData.equipment_changed.emit()
	#print(PlayerData.player_data.get("Equipment"))


#func _drop_data(_at_position: Vector2, _data: Variant) -> void:	
	#GlobalData.character_sheet_busy_dragging = false
	#var target_equipment_slot = get_parent().get_name()
	#var origin_slot = _data.get("origin_node").get_parent().get_name()
	#var inv_changed = false
	#play_sfx(_data.get("origin_item_id"), "_drop")
	#
	#if _data.get("origin_panel") == "Inventory":
		#if _data.get("target_item_id") == null:
			##nothing in equipment slot, so remove the inventory item
			#var original_inventory_item = PlayerDataMain.remove_inventory_item(_data.get("origin_inventory_index"))
			#PlayerDataMain.set_equipment_data(target_equipment_slot, original_inventory_item.get("instance_ids").get(0))
			#inv_changed = true
		#else: # Swap items
			#var original_inventory_item = PlayerDataMain.get_inventory_item(_data.get("origin_inventory_index"))
			#var item_instance = GamesInstanceData.item_instance_data.get(PlayerDataMain.get_equipment_data(target_equipment_slot))
			#
			#var new_original_inventory_item = {
				#"id": item_instance.get("id"),
				#"instance_ids": [PlayerDataMain.get_equipment_data(target_equipment_slot)]
			#}
			## set inventory
			#PlayerDataMain.set_inventory_item(_data.get("origin_inventory_index"), new_original_inventory_item)
			#inv_changed = true
			## set equipemtn
			#PlayerDataMain.set_equipment_data(target_equipment_slot, original_inventory_item.get("instance_ids").get(0))
	#else:#??
		#PlayerDataMain.set_equipment_data(origin_slot, _data.get("target_item_inst_id"))
	#
	#if _data.get("origin_panel") == "Equipment" and _data.get("target_item_inst_id") == null:
		## Load the default background icons for the Equipment places
		#var default_texture = load("res://assets/hud/ui screen/elements/equipment/" + origin_slot + "_default_icon.png")
		#_data.get("origin_node").texture = default_texture
	#
	#texture = _data.get("origin_texture")
	#if inv_changed:
		#GlobalData.inventory_changed.emit()


func _on_mouse_entered() -> void:
	if GlobalData.character_sheet_busy_dragging:
		return
	var panel = get_node("../../../../../../").get_name()
	if panel == "InputContainer":
		panel = get_node("../../../../../").get_name()
	else:
		return # TODO Handle others inventory
		
	var rtl = get_node("../../../../InventoryTitle/NinePatchRect/HBoxContainer/Tooltip")
	var slot_name = get_parent().get_name()
	var slot_index = slot_name.substr(13)
	var inventory_item = PlayerData.get_inventory_item(int(slot_index) - 1)
	if inventory_item == null:
		return
	var item_id = inventory_item.get("id")
	if item_id == null:
		return
	var item = GameData.item_data.get(item_id)
	var message = "[outline_size=2][font_size=16]" + tr("item." + item_id + ".name") + "[/font_size][/outline_size]\n" + tr("item." + item_id + ".description") + "\n"
	for ii in inventory_item.get("instance_ids"):
		message += "[" + ii + "] "
	message += "\n"
	for i in GameData.STATS.size():
		var stat = GameData.STATS[i]
		if item.has("EQUIPMENT") and item.get("EQUIPMENT").get(stat) != null and item.get("EQUIPMENT").get(stat) > 0.0:
			message += tr("equipment.stat." + stat.to_lower()).to_upper() + ": " + str(item.get("EQUIPMENT").get(stat)) + " "
			var font_colour_start = ""
			var font_colour_end = ""
			if panel != "Inv2InvScreen" and GameData.item_data.get(item_id).get("EQUIPMENT").get("SLOT") != null: # and origin == "Inventory":
				var stat_difference = compare_stat(item, stat, item.get("EQUIPMENT").get(stat))
				if stat_difference > 0:
					font_colour_start = "[color=#3eff00]"
					font_colour_end = "[/color]"
				elif stat_difference < 0:
					font_colour_start = "[color=#ff0000]"
					font_colour_end = "[/color]"
				message += "(" + font_colour_start + str(stat_difference) + font_colour_end + ") "
	if rtl != null:
		rtl.set_text(message)


func compare_stat(item, stat_name, stat_value):
	var stat_difference
	var equipment_slot = item.get("EQUIPMENT").get("SLOT")
	if PlayerData.get_equipment_data(equipment_slot) != null:
		var current_item_instance_id = PlayerData.get_equipment_data(equipment_slot)
		var current_item_id = GameInstanceData.item_instance_data.get(current_item_instance_id).get("id")
		var current_stat_value = GameData.item_data.get(current_item_id).get("EQUIPMENT").get(stat_name)
		if current_stat_value == null:
			current_stat_value = 0.0
		stat_difference = stat_value - current_stat_value
	else:
		stat_difference = stat_value
	return stat_difference


func _on_mouse_exited() -> void:
	if GlobalData.character_sheet_busy_dragging:
		return
		
	var rtl = get_node("../../../../InventoryTitle/NinePatchRect/RichTextLabel")
	if rtl != null:
		rtl.set_text("")


func split_stack(_split_amount: int, _data):
	pass
	#var target_inventory_slot = get_parent().get_name()
	#var origin_slot = _data.get("origin_node").get_parent().get_name()
	#
	##var new_stack_amount = _data["origin_stack"] - _split_amount
	#if _data.get("origin_panel") == "Inventory":
		#var target_stack = PlayerData.destack_inventory_item(_data.get("origin_inventory_index"), _split_amount)
		#if not _data.has("target_inventory_index") or _data.get("target_inventory_index") < 0:
			#var new_inventory_item = {
				#"id": _data.get("origin_inventory_item").get("id"),
				#"instance_ids": []
			#}
			#_data.set("target_inventory_index", PlayerData.append_inventory_item(new_inventory_item))
		#PlayerData.stack_inventory_item(_data.get("target_inventory_index"), target_stack)
		#if _data.get("origin_inventory_item").get("instance_ids").size() == 0:
			#PlayerData.remove_inventory_item(_data.get("origin_inventory_index"))
		#GlobalData.inventory_changed.emit()


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
