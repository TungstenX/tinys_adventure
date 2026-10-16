extends PopupPanel

var data

func _ready() -> void:
	get_node("N/H/Amount").grab_focus()
	unresizable = false


func _on_confirm_pressed() -> void:
	var split_amount = get_node("N/H/Amount").get_text()
	if split_amount == "":
		split_amount = 1

	if int(split_amount) >= data["origin_inventory_item"]["instance_ids"].size():
		split_amount = data["origin_inventory_item"]["instance_ids"].size() - 1
	get_parent().split_stack(int(split_amount), data)
	self.queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_confirm_pressed()
