extends Node2D

var spawn_skull: bool = false
var node: Node2D

func _ready() -> void:
	$AnimationPlayer.play("death")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if spawn_skull:
		var skull_spawn_packed: PackedScene = load("res://scenes/effects/skull_spawn.tscn")
		var skull_spawn = skull_spawn_packed.instantiate()
		skull_spawn.position = position
		skull_spawn.node = node
		get_parent().add_child(skull_spawn)
	queue_free()
