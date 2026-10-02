extends Node

signal popup_menu_selected(parent: Node2D, selected_index: int)

enum InventoryType {
	COIN,
	MUSHROOM
}

enum MobType {
	RED_UNIT,
	THIEF,
	SKULL
}

var derived_base_per_level
var mob_data
var npc_data

func _ready():
	load_derived_base_per_level_data()
	load_mob_data()
	load_npc_data()


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


func get_max_per_level(which: String, player_level: int) -> float:
	return derived_base_per_level.get("LEVELS").get(which).get(player_level - 1)


func get_recovery_per_level(which: String, player_level: int) -> float:
	return derived_base_per_level.get("RECOVERY").get(which).get(player_level - 1)


func get_mob_data_for(which: String) -> Variant:
	return mob_data.get(which)


func get_npc_data_for(which: String) -> Variant:
	return npc_data.get(which)
