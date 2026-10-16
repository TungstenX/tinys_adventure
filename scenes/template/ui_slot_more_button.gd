extends Control

@export_category("Book Settings")
@export var book_page: String = "book"
@export var book_hot_key: String = "B"
@export var narrow: bool = true

func _ready() -> void:
	get_node("N/Key").set_text(book_hot_key.to_upper())
	if not narrow:
		set_size(Vector2(88, 64))
		get_node("N").size = Vector2(88, 64)
		

func _on_tb_pressed() -> void:
	var book: Control = get_tree().get_nodes_in_group("book")[0]
	book.set_page(book_page)
	book.get_tree().get_nodes_in_group("book")[0].show_book()
