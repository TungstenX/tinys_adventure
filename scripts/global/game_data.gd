extends Node

@warning_ignore("unused_signal")
signal popup_menu_selected(parent: Node2D, selected_index: int)
@warning_ignore("unused_signal")
signal switch_tiggered(id:int, on: bool)
@warning_ignore("unused_signal")
signal inventory_changed
@warning_ignore("unused_signal")
signal equipment_changed
@warning_ignore("unused_signal")
signal trophy_changed

const STATS = ["DAMAGE", "ATTACK_SPEED", "RANGE", "ARMOR", "DEFENCE"]


enum MobType {
	RED_UNIT,
	THIEF,
	SKULL
}

var derived_base_per_level: Dictionary
var mob_data: Dictionary
var npc_data: Dictionary
var item_template_data: Dictionary

func _ready():
	load_derived_base_per_level_data()
	load_mob_data()
	load_npc_data()
	load_item_template_data()


func load_derived_base_per_level_data():
	var derived_base_per_level_file = FileAccess.open("res://data/DerivedBasePerLevel.json", FileAccess.READ)
	derived_base_per_level = JSON.parse_string(derived_base_per_level_file.get_as_text())
	derived_base_per_level_file.close()


func load_mob_data():
	var mob_file = FileAccess.open("res://data/MobData.json", FileAccess.READ)
	mob_data = JSON.parse_string(mob_file.get_as_text())
	mob_file.close()


func load_npc_data():
	var npc_file = FileAccess.open("res://data/NpcData.json", FileAccess.READ)
	npc_data = JSON.parse_string(npc_file.get_as_text())
	npc_file.close()


func load_item_template_data():
	var item_file = FileAccess.open("res://data/ItemData.json", FileAccess.READ)
	item_template_data = JSON.parse_string(item_file.get_as_text())
	item_file.close()


func get_max_per_level(which: String, player_level: int) -> float:
	return derived_base_per_level.get("LEVELS").get(which).get(player_level - 1)


func get_recovery_per_level(which: String, player_level: int) -> float:
	return derived_base_per_level.get("RECOVERY").get(which).get(player_level - 1)


func get_mob_data_for(which: String) -> Variant:
	return mob_data.get(which)


func get_npc_data_for(which: String) -> Variant:
	return npc_data.get(which)


func get_item_template(_template_id: String) -> Variant:
	if item_template_data.has(_template_id):
		return item_template_data.get(_template_id)
	else:
		return null
