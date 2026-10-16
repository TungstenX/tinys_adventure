extends Control

const SLOTS = ["head", "body", "legs", "mainhand", "offhand", "hands"]
const SLOTS_COL = ["Col1", "Col1", "Col3", "Col3", "Col1", "Col3"]

func _ready() -> void:
	update_slots()
	#update_buttons()
	GameData.equipment_changed.connect(update_slots)


func update_slots() -> void:
	var i: int = 0
	for slot_name in SLOTS:		
		var col: String = SLOTS_COL[i]
		var inventory_slot = get_node("HMain/Row1/" + col + "/" + slot_name.capitalize())
		var added_icon = false
		if PlayerData.has_equipment_data(slot_name):
			var slot = PlayerData.get_equipment_data(slot_name)
			if slot != null:
				var item_instance = GameInstanceData.get_item_instance(slot)
				if item_instance != null:
					var item_template = GameData.get_item_template(item_instance.get("template_id"))
					var item_icon = item_template.get("ICON")
					var icon_texture = load("res://assets/ui/elements/inventory/icon_" + item_icon + ".png")
					if icon_texture != null:
						inventory_slot.set_icon(icon_texture)
						added_icon = true
		if not added_icon:
			set_default_icon(slot_name, inventory_slot)
		i += 1

func set_default_icon(slot_name: String, inventory_slot) -> void:
	var icon_texture = load("res://assets/ui/art/equipment_" + slot_name + ".png")
	inventory_slot.set_icon(icon_texture)
	
