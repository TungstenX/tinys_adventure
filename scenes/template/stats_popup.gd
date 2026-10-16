extends PopupPanel

@export var text: String = ""

func _ready() -> void:
	get_node("N/H/RichTextLabel").set_text(text)
	print(get_node("N/H/RichTextLabel").get_line_count())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()


func _on_texture_button_pressed() -> void:
	queue_free()
