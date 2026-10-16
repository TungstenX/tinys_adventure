extends NPC

@export_category("Building Settings")
@export var texture: Texture2D
@export var texture_destroyed: Texture2D
@export var blocking_collision_layer: int = 3
@export var destroyed: bool = false

var fx_destroy_timer: Timer
@onready var dust_packed: PackedScene = load("res://scenes/effects/dust.tscn")

func _ready() -> void:
	npc_type = "TOWER"
	do_ready()
	if destroyed:
		get_node("Sprite2D").texture = texture_destroyed
		get_node(".").collision_layer = 1
	else:
		get_node("Sprite2D").texture = texture
		get_node(".").collision_layer = collision_layer
	

#func take_damage(damage_taken: int) -> void:
	#if destroyed:
		#return
	#fx_take_damage()
	#hitpoints -= damage_taken
	#update_hp_bar()
	#
	#if hitpoints <= 0:
		#death()

func death() -> void:
	destroyed = true
	get_node("HurtBox").set_visible(false)
	get_node("HP").set_visible(false)
	get_node(".").collision_layer = 1
	var dust = dust_packed.instantiate()
	dust.position = global_position + Vector2(0.0, -32.0)
	dust.scale = Vector2(2.0, 2.0)
	add_child(dust)
	if fx_destroy_timer == null:
		fx_destroy_timer = Timer.new()
		add_child(fx_destroy_timer)
		fx_destroy_timer.wait_time = 0.8
		fx_destroy_timer.timeout.connect(fx_destroy_timeout)
		fx_destroy_timer.start()


func fx_destroy_timeout() -> void:
	if fx_destroy_timer != null:
		fx_destroy_timer.stop()
		remove_child(fx_destroy_timer)
		fx_destroy_timer.queue_free()
		get_node("Sprite2D").texture = texture_destroyed
		


func _on_hurt_box_mouse_entered_tower() -> void:
	_on_hurtbox_mouse_entered()


func _on_hurt_box_mouse_exited_tower() -> void:
	_on_hurtbox_mouse_exited()
