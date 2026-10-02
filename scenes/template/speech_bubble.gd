extends Control

@export_category("Stats")
@export var hp: String
@export var atk: String
@export var def: String


#TODO Make a real speech bubble
#This is more like a stats bubble for now
func _ready() -> void:
	update_text()


func update_text() -> void:
	get_node("BG/V/HP/Label").set_text(hp)
	get_node("BG/V/ATK/Label").set_text(atk)
	get_node("BG/V/DEF/Label").set_text(def)
