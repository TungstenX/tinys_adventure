extends Node2D

enum InventoryType {
	COIN,
	MUSHROOM
}

@export_category("Prop")
@export var prop_texture: Texture2D
@export var prop_type: InventoryType
@export var prop_size: int
@export_category("Stats")
@export var hitpoints: int = 1

var harvest_range: int = 64
var notify_range: int = 128
var in_range: bool = false

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var speech_bubble = get_node("SpeechBubble")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var cursor_arrow = load("res://assets/ui/pointers/01.png")
var cursor_grab = load("res://assets/ui/pointers/Cursor_02.png")

func _ready() -> void:
	if prop_texture != null:
		get_node("Sprite2D").set_texture(prop_texture)


func _physics_process(_delta: float) -> void:
	if distance_to_player() <= harvest_range:
		in_range = true
		if not animation_player.is_playing():
			animation_player.set_active(true)
			animation_player.current_animation = "hop"
			animation_player.play()
		#if speech_bubble.is_visible():
			#speech_bubble.set_visible(false)
	elif distance_to_player() <= notify_range:
		in_range = false
		if animation_player.is_playing():
			animation_player.stop()
		#if not speech_bubble.is_visible():
			#speech_bubble.set_visible(true)
	else:
		in_range = false
		if animation_player.is_playing():
			animation_player.stop()
		#if speech_bubble.is_visible():
			#speech_bubble.set_visible(false)


func take_damage(damage_taken: int) -> void:
	fx_take_damage()
	hitpoints -= damage_taken
	if hitpoints <= 0:
		death()


func fx_take_damage() -> void:
	pass


func death() -> void:
	player.add_to_inventory(prop_size, prop_type)
	queue_free()


func _on_area_2d_mouse_entered() -> void:
	get_node("Sprite2D").modulate = Color.YELLOW
	Input.set_custom_mouse_cursor(cursor_grab)


func _on_hurt_box_mouse_exited() -> void:
	get_node("Sprite2D").modulate = Color.WHITE
	Input.set_custom_mouse_cursor(cursor_arrow)


func distance_to_player() -> float:
	return global_position.distance_to(player.global_position)


func _on_hurt_box_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if in_range:
			death()
