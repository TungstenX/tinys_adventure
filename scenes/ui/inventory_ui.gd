extends Control

signal page_up_pressed(owner: Control)
signal page_down_pressed(owner: Control)

@onready var inventory_grid: GridContainer = get_node("VMain/S/V/G")
@export_category("Inventory Page Settings")
@export var icon: Texture2D
@export var title: String = ""
@export var fixed_first_6: bool = true
@export var disabled_up_button: bool = true
@export var disabled_down_button: bool = true

var inventory_source = PlayerData

func _ready() -> void:
	update_heading()
	create_inventory_slots()
	update_buttons()
	GameData.inventory_changed.connect(update_slots)


func create_inventory_slots() -> void:
	if inventory_source == null or not inventory_source.has_method("get_inventory_capacity_number_of_slots"):
		return
	var template_inv_slot = load("res://scenes/template/inventory_slot_ui.tscn")
	var number_of_slots = inventory_source.get_inventory_capacity_number_of_slots() # PlayerData.player_data.get("inventory_capacity").get("number_of_slots")
	
	for index in number_of_slots:
		var inventory_slot
		if index <= 5 and fixed_first_6:
			inventory_slot = get_node("VMain/S/V/G/InventorySlotUI" + str(index + 1))
			if not fixed_first_6:
				inventory_slot.HotListNumber.set_visible(false)
		else:
			inventory_slot = template_inv_slot.instantiate()
		update_slot(index + 1, inventory_slot)
		if index > 5 or not fixed_first_6:
			inventory_grid.add_child(inventory_slot, true)


func update_slot(index: int, inventory_slot) -> void:
	if inventory_source == null or not inventory_source.has_method("get_inventory_item"):
		return
	var inventory_item = inventory_source.get_inventory_item(index)
	if inventory_item == null:
		inventory_slot.set_icon(null)
		inventory_slot.set_amount(0)
		return
	var item_instance_ids = inventory_item.get("instance_ids")
	var first_item_instance_ids = item_instance_ids[0]
	var item_instance = GameInstanceData.get_item_instance(first_item_instance_ids)
	var item_template_id = item_instance.get("template_id")
	var item_icon = GameData.get_item_template(item_template_id).get("ICON")
	var icon_texture = load("res://assets/ui/elements/inventory/icon_" + item_icon + ".png")
	inventory_slot.set_icon(icon_texture)
	var item_stack = inventory_item.get("instance_ids").size()
	if item_stack != null and item_stack > 1:
		inventory_slot.set_amount(item_stack)


func update_slots() -> void:
	if inventory_source == null or not inventory_source.has_method("get_inventory_capacity_number_of_slots"):
		return
	for index in inventory_source.get_inventory_capacity_number_of_slots():
		var inventory_slot = get_node("VMain/S/V/G/InventorySlotUI" + str(index + 1))
		if inventory_slot == null:
			var template_inv_slot = load("res://scenes/template/inventory_slot_ui.tscn")
			inventory_slot = template_inv_slot.instantiate()
			inventory_grid.add_child(inventory_slot, true)
		update_slot(index + 1, inventory_slot)


func update_heading() -> void:
	get_node("VMain/Header/Icon").set_texture(icon)
	get_node("VMain/Header/Title").set_text(title)


func update_buttons() -> void:
	if disabled_up_button:
		get_node("VMain/Buttons/Previous").set_disabled(true)
	else:
		get_node("VMain/Buttons/Previous").set_disabled(false)
	if disabled_down_button:
		get_node("VMain/Buttons/Next").set_disabled(true)
	else:
		get_node("VMain/Buttons/Next").set_disabled(false)
	
	if get_node("VMain/Buttons/Previous").is_disabled():
		get_node("VMain/Buttons/Previous/Label").set("theme_override_colors/font_color", Color("808080"))
	else:
		get_node("VMain/Buttons/Previous/Label").set("theme_override_colors/font_color", Color("ffffff"))
	if get_node("VMain/Buttons/Next").is_disabled():
		get_node("VMain/Buttons/Next/Label").set("theme_override_colors/font_color", Color("808080"))
	else:
		get_node("VMain/Buttons/Next/Label").set("theme_override_colors/font_color", Color("ffffff"))


func _on_next_button_down() -> void:
	get_node("VMain/Buttons/Next/Label").position.y = -5


func _on_next_button_up() -> void:
	get_node("VMain/Buttons/Next/Label").position.y = -8


func _on_next_pressed() -> void:
	page_up_pressed.emit(self)


func _on_previous_button_down() -> void:
	get_node("VMain/Buttons/Previous/Label").position.y = -5


func _on_previous_button_up() -> void:
	get_node("VMain/Buttons/Previous/Label").position.y = -8


func _on_previous_pressed() -> void:
	page_down_pressed.emit(self)


#TODO: Check is allowed to show and or interact with inventory
func set_inventory_source(entity) -> void:
	for slot in inventory_grid.get_children():
		inventory_grid.remove_child(slot)
		slot.queue_free()
	inventory_source = entity
	
	if inventory_source != null and inventory_source.has_method("get_inventory_name"):
		title = inventory_source.get_inventory_name()
	
	if inventory_source != null and inventory_source.has_method("get_inventory_icon"):
		icon = load("res://assets/ui/avatars/" + inventory_source.get_inventory_icon() + ".png")
	update_heading()
	create_inventory_slots()
	update_buttons()

func remove_all_stats_popups() -> void:
	for slot in get_node("VMain/S/V/G").get_children():
		if slot.has_node("Icon") and slot.get_node("Icon").has_node("StatsPopup"):
			slot.get_node("Icon").get_node("StatsPopup").queue_free()
