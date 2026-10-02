extends Node2D

@onready var skull_packed: PackedScene = load("res://scenes/entities/enemies/skull.tscn")
var node: Node2D


func _ready() -> void:
	$AnimationPlayer.play("spawn")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	var skull = skull_packed.instantiate()
	skull.position = position #	global_position + Vector2(0.0, -32.0)
	skull.mob_type = GameData.MobType.SKULL
	node.add_child(skull)
	queue_free()
