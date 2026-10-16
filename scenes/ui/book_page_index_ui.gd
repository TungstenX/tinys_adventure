extends Control

func _ready() -> void:
	for action_name in InputMap.get_actions():
		for inputEvent in InputMap.action_get_events(action_name):
			if has_node("VMain/S/V/" + action_name + "/KeyButton/Label"):
				get_node("VMain/S/V/" + action_name + "/KeyButton/Label").set_text(inputEvent.as_text().substr(0,1).to_upper())


func _on_text_button_inv_pressed() -> void:
	get_node("../../").set_page("inventory")


func _on_key_button_inv_pressed() -> void:
	get_node("../../").set_page("inventory")


func _on_text_button_eqp_pressed() -> void:
	get_node("../../").set_page("equipment")


func _on_key_button_eqp_pressed() -> void:
	get_node("../../").set_page("equipment")


func _on_text_button_trophy_pressed() -> void:
	get_node("../../").set_page("trophies")


func _on_key_button_trophy_pressed() -> void:
	get_node("../../").set_page("trophies")


func _on_text_button_recipes_pressed() -> void:
	get_node("../../").set_page("recipes")


func _on_key_button_recipes_pressed() -> void:
	get_node("../../").set_page("recipes")


func _on_text_button_stats_pressed() -> void:
	pass # Replace with function body.


func _on_key_button_stats_pressed() -> void:
	pass # Replace with function body.


func _on_text_button_skills_pressed() -> void:
	pass # Replace with function body.


func _on_key_button_skills_pressed() -> void:
	pass # Replace with function body.
