extends Node

var item_instance_data: Dictionary = {}

func _ready() -> void:
	load_item_instance_data()


func load_item_instance_data() -> void:
	if FileAccess.file_exists("user://ItemInstanceData.json"):
		var ii_data_file = FileAccess.open("user://ItemInstanceData.json", FileAccess.READ)
		item_instance_data = JSON.parse_string(ii_data_file.get_as_text())
		ii_data_file.close()
	else:
		load_first_item_instance_data()
	#process_loaded_buffs()


func load_first_item_instance_data() -> void:
	var ii_data_file = FileAccess.open("res://data/ItemInstanceData.json", FileAccess.READ)
	item_instance_data = JSON.parse_string(ii_data_file.get_as_text())
	ii_data_file.close()
	save_item_instance_data()


func save_item_instance_data():
	var file = FileAccess.open("user://ItemInstanceData.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(item_instance_data, "\t"))
	file.close()
	pass


func add_item_instance(instance: Dictionary) -> void:
	item_instance_data.set(instance.get("id"), instance)


func get_item_instance(id: String) -> Variant:
	if item_instance_data.has(id):
		return item_instance_data.get(id)
	return null
