extends Control

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@export_category("Book Settings")
@export var max_distance_for_inventory_loop_up: int = 128

var should_close: bool = true
var old_page_name: String = ""


# TODO: Don't close book if different key is press. E.g. first key was B and then the second one was I (to page to I)
func _ready() -> void:
	get_node("Sides/InventoryOther").page_up_pressed.connect(page_previous_pressed)
	get_node("Sides/InventoryOther").page_down_pressed.connect(page_next_pressed)
	set_other_inventory(null)
	GameData.trophy_changed.connect(update_throphies)


func page_previous_pressed(_owner: Control) -> void:
	pass


func page_next_pressed(_owner: Control) -> void:
	pass


func toggle_visible() -> void:
	if is_visible():
		hide_book()
	else:
		show_book()


func show_book() -> void:
	# find nearest npc or container
	var entity = null
	var distance = max_distance_for_inventory_loop_up
	for npc in get_tree().get_nodes_in_group("npc"):
		var npc_distance = npc.position.distance_to(player.global_position)
		if npc_distance < distance:
			distance = npc_distance
			entity = npc
	set_other_inventory(entity)
	# same for containers
	
	set_visible(true)


func hide_book() -> void:
	if should_close:
		set_visible(false)


func set_other_inventory(entity) -> void:
	get_node("Sides/InventoryOther").set_inventory_source(entity)


func _on_texture_button_pressed() -> void:
	should_close = true
	hide_book()


func set_page(page_name: String) -> void:
	should_close = old_page_name == "" or old_page_name == page_name
	old_page_name = page_name
	for page in get_node("Sides").get_children():
		page.set_visible(false)
	match page_name:
		"book":
			get_node("Sides/BookPageIndex").set_visible(true)
			get_node("Sides/BookPageIndex2").set_visible(true)
		"inventory":
			get_node("Sides/InventoryOther").set_visible(true)
			get_node("Sides/InventoryPlayer").set_visible(true)
		"equipment":
			get_node("Sides/BookPageEquipment").set_visible(true)
			get_node("Sides/InventoryPlayer").set_visible(true)
		"trophies":
			get_node("Sides/BookPageTrophies1").set_visible(true)
			get_node("Sides/BookPageTrophies2").set_visible(true)
		_:
			get_node("Sides/BookPageBlank").set_visible(true)
			get_node("Sides/BookPageBlank2").set_visible(true)
			


func update_throphies() -> void:
	for throphy_name in PlayerData.get_trophies():
		var throphy = PlayerData.get_trophies().get(throphy_name)
		if throphy.enemy:
			get_node("Sides/BookPageTrophies1").update_amount(throphy.name, throphy.amount)
		else:
			get_node("Sides/BookPageTrophies2").update_amount(throphy.name, throphy.amount)
