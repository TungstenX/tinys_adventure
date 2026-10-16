extends Node2D

@export var attack_damage: int
@export var aoe_radius: int
@export var scale_me: Vector2 = Vector2(1.0, 1.0)
@export var attack_type: Array

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	get_node("AnimationPlayer").play("explode")
	get_node("Sprite2D").scale = scale_me


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()

func aoe_damage() -> void:
	var player_distance: float = distance_to_player()
	var a_t = []
	if attack_type == null or attack_type.is_empty():
		attack_type = ["NONE", "NONE"]
	a_t.append(attack_type[1])
	if  player_distance <= aoe_radius:
		var actual_damage: float = attack_damage * ((aoe_radius - player_distance)/aoe_radius)
		player.take_damage(actual_damage, a_t)
		
	for npc in get_tree().get_nodes_in_group("npc"):
		var distance: float = global_position.distance_to(npc.global_position)
		if distance <= aoe_radius and npc.has_method("take_damage"):
			var actual_damage: float = attack_damage * ((aoe_radius - distance)/aoe_radius)
			npc.take_damage(actual_damage, a_t)

func distance_to_player() -> float:
	return global_position.distance_to(player.global_position)
	
