extends Node2D
# TODO: Wire up for npc and mob
enum SwitchType {
	PLAYER,
	NPC,
	MOB
}

@onready var player = get_tree().get_first_node_in_group("player")
@export_category("Switch settings")
@export var id: int = 0
@export var number_of_firing: int = 1
@export var target: SwitchType = SwitchType.PLAYER
@export var sense_level: int = -1

func _ready() -> void:
	if sense_level > -1:
		get_node("AnimationPlayer").play("idle")
		# get player trap sense 
		var player_trap_sense = 0
		var transp = "00"
		if sense_level <= player_trap_sense:
			transp = "ff"
		elif sense_level == player_trap_sense + 1:
			transp = "80"
		elif sense_level == player_trap_sense + 2:
			transp = "40"
		elif sense_level == player_trap_sense + 3:
			transp = "20"
		get_node("Sprite2D").modulate = Color("ffffff" + transp)
	else:
		get_node("Sprite2D").set_visible(false)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if target == SwitchType.PLAYER and body != player:
		return
	if number_of_firing > 0 or number_of_firing < -1:
		GameData.switch_tiggered.emit(id, true)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if target == SwitchType.PLAYER and body != player:
		return
	if number_of_firing > 0 or number_of_firing < -1:
		number_of_firing -= 1
		GameData.switch_tiggered.emit(id, false)
