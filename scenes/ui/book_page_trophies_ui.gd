extends Control

@export_category("Page Trophies Settings")
@export var title: String
@export var enemy_trophy_game: bool = true

@onready var trophy_packed: PackedScene = load("res://scenes/template/trophy_slot_ui.tscn")

func _ready() -> void:
	get_node("VMain/Header/Title").set_text(title)


func is_enemy_trophy_game() -> bool:
	return enemy_trophy_game


func add_trophy(npc_name: String, amount: int) -> void:
	var icon: Texture2D = load("res://assets/ui/avatars/" + npc_name + "_Avatar.png")
	var trophy = trophy_packed.instantiate()
	trophy.icon = icon
	trophy.amount = amount
	trophy.npc_name = "ui.trophy.name." + npc_name.to_lower().replace(" ", "_")
	get_node("VMain/S/V/G").add_child(trophy)

func update_amount(npc_name: String, amount: int) -> void:
	for trophy in get_node("VMain/S/V/G").get_children():
		if trophy.npc_name == "ui.trophy.name." + npc_name.to_lower().replace(" ", "_"):
			trophy.set_amount(amount)
			return
	add_trophy(npc_name, amount)
