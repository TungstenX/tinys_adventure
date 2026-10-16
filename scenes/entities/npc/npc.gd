class_name NPC
extends CharacterBody2D

signal died(exp: int)

enum State {
	IDLE,
	FOLLOW,
	CHASE,
	RETURN,
	ATTACK,
	DEAD
}

enum NpcBehaviour {
	NORMAL,
	CANT_MOVE,
	SLEEP
}

@export_category("Related Scenes")
@export var death_packed: PackedScene
@export_category("Mod Type")
@export var npc_type: String
@export var npc_level: int = 1
@export_category("Mod Behaviour")
@export var npc_behaviour: NpcBehaviour = NpcBehaviour.NORMAL

@export_category("Popup Menu List")
@export var row_1_col_1a: String
@export var row_1_col_1b: Texture2D
@export var row_1_col_2a: String
@export var row_1_col_2b: Texture2D
@export var row_1_col_3a: String
@export var row_1_col_3b: Texture2D

@export var row_2_col_1a: String
@export var row_2_col_1b: Texture2D
@export var row_2_col_2a: String
@export var row_2_col_2b: Texture2D
@export var row_2_col_3a: String
@export var row_2_col_3b: Texture2D

@export var row_3_col_1a: String
@export var row_3_col_1b: Texture2D
@export var row_3_col_2a: String
@export var row_3_col_2b: Texture2D
@export var row_3_col_3a: String
@export var row_3_col_3b: Texture2D

var state: State = State.IDLE
# Stats
# TODO: Move to json file
var speed: int = 128
var attack_damage: int = 10
var attack_speed: float = 1.0
var hitpoints: int = 180
var hitpoints_max: int = 180
var defence: int = 20
var agro_range: float = 256.0
var follow_range_max: float = 256.0
var follow_range_min: float = 64.0
var attack_range: float = 80.0
var exp_reward: int = 600
var fx_timer: Timer
var speech_timer: Timer
var target: CharacterBody2D
var hired: bool = false
var number_of_actions: int = 0
var face_icon: Texture2D
var economy: Dictionary

@onready var spawn_point: Vector2 = global_position
@onready var animation_tree: AnimationTree = get_node("AnimationTree")
#@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
var animation_playback: AnimationNodeStateMachinePlayback
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var nav_agent: NavigationAgent2D = get_node("NavigationAgent2D")
@onready var arrow_packed: PackedScene = load("res://scenes/entities/projectile/arrow.tscn")
@onready var speech_bubble: Control = get_node("SpeechBubble")

func _ready() -> void:
	do_ready()


func do_ready() -> void:		
	if animation_tree != null:
		animation_playback = $AnimationTree["parameters/playback"]
	var npc_data = GameData.get_npc_data_for(npc_type)
	speed = npc_data.get("SPEED").get(npc_level - 1)
	attack_damage = npc_data.get("ATTACK_DAMAGE").get(npc_level - 1)
	attack_speed = npc_data.get("ATTACK_SPEED").get(npc_level - 1)
	defence = npc_data.get("DEFENCE").get(npc_level - 1)
	hitpoints = npc_data.get("HITPOINTS").get(npc_level - 1)
	hitpoints_max = hitpoints
	agro_range = npc_data.get("AGRO_RANGE").get(npc_level - 1)
	attack_range = npc_data.get("ATTACK_RANGE").get(npc_level - 1)
	exp_reward = npc_data.get("EXP_REWARD").get(npc_level - 1)
	if npc_data.has("ECONOMY"):
		economy = npc_data.get("ECONOMY")
	if animation_tree != null:
		animation_tree.set_active(true)
	var popup_menu = get_node("PopupMenu")
	if popup_menu != null:
		popup_menu.update_menu(row_1_col_1a, row_1_col_1b, row_1_col_2a, row_1_col_2b, row_1_col_3a, row_1_col_3b, \
			row_2_col_1a, row_2_col_1b, row_2_col_2a, row_2_col_2b, row_2_col_3a, row_2_col_3b, \
			row_3_col_1a, row_3_col_1b, row_3_col_2a, row_3_col_2b, row_3_col_3a, row_3_col_3b)
	
	if npc_data.has(npc_type):
		face_icon = load("res://assets/ui/avatars/" + npc_data.get(npc_type) + ".png")
	
	update_speech_bubble()
	print("Npc: ", get_node(".").get_name())


func _physics_process(_delta: float) -> void:
	if state == State.DEAD:
		return
	if state == State.ATTACK:
		return
	if hired:
		var dist_to_player = distance_to_player()
		var dist_to_target = distance_to_target()
		if target != null:
			if dist_to_target <= attack_range:
				state = State.ATTACK
				attack()
			elif dist_to_target <= agro_range:
				start_agro()
				state = State.CHASE
				move()
			elif dist_to_player <= follow_range_max:
				state = State.FOLLOW
				if dist_to_player >= follow_range_min:
					move()
				else:
					update_animation()
			elif state != State.IDLE:
				state = State.IDLE
				update_animation()
		elif dist_to_player <= follow_range_max:
			state = State.FOLLOW
			if dist_to_player >= follow_range_min:
				move()
			else:
				update_animation()
		elif state != State.IDLE:
			state = State.IDLE
			update_animation()
	elif global_position.distance_to(spawn_point) > 32:
		end_agro()
		state = State.RETURN
		move()
	elif state != State.IDLE:
		state = State.IDLE
		update_animation()


func distance_to_player() -> float:
	return global_position.distance_to(player.global_position)


func distance_to_target() -> float:
	if target != null:
		return global_position.distance_to(target.global_position)
	return 0 # ??


func move() -> void:
	if npc_behaviour == NpcBehaviour.CANT_MOVE:
		return
	if target != null and state == State.CHASE:
		nav_agent.target_position = target.global_position
	elif state == State.FOLLOW:
		nav_agent.target_position = player.global_position
	elif state == State.RETURN:
		nav_agent.target_position = spawn_point
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * speed
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(velocity)
	move_and_slide()
	
	if state == State.IDLE or State.FOLLOW or State.CHASE:
		if velocity.x < -0.01:
			$Sprite2D.flip_h = true
		elif velocity.x > 0.01:
			$Sprite2D.flip_h = false
			
	update_animation()


func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.FOLLOW:
			animation_playback.travel("run")
		State.CHASE:
			animation_playback.travel("run")
		State.RETURN:
			animation_playback.travel("run")
		State.ATTACK:
			animation_playback.travel("attack")
		State.DEAD:
			pass


func update_speech_bubble() -> void:
	if speech_bubble != null:
		speech_bubble.hp = str(hitpoints)
		speech_bubble.atk = str(attack_damage)
		speech_bubble.def = str(defence)
		speech_bubble.update_text()


#TODO Update this
func start_agro() -> void:
	if state != State.FOLLOW:
		get_node("../../Player/PlayerCamera").set_zoom(Vector2(1.25, 1.25))
		#if speech_bubble != null:
			#speech_bubble.set_visible(true)
		if speech_timer != null:
			speech_timer = Timer.new()
			add_child(speech_timer)
			speech_timer.wait_time = .5
			speech_timer.timeout.connect(end_agro)
			speech_timer.start()


#TODO Update this
func end_agro() -> void:
	if speech_timer != null:
		speech_timer.stop()
		speech_timer.queue_free()
	if get_node("../../Player/PlayerCamera").get_zoom() > Vector2(1, 1):
		get_node("../../Player/PlayerCamera").set_zoom(Vector2(1, 1))
	if speech_bubble != null and speech_bubble.is_visible():
		speech_bubble.set_visible(false)


func attack() -> void:
	if target == null:
		return
	var target_pos: Vector2 = target.global_position
	var attack_dir: Vector2 = (target_pos - global_position).normalized()
	$Sprite2D.flip_h = attack_dir.x < 0 # and abs(attack_dir.x) >= abs(attack_dir.y)
	animation_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir)
	update_animation()
	
	await get_tree().create_timer(attack_speed).timeout
	fire()
	state = State.IDLE
	number_of_actions -= 1
	if number_of_actions == 0:
		hired = false


#TODO: Add by whom, if player then warn
func take_damage(damage_taken: int, _a_t: Array) -> void:
	fx_take_damage()
	defence -= damage_taken
	if defence <= 0:
		hitpoints += defence
		defence = 0
		update_hp_bar()
		if hitpoints <= 0:
			death()
	update_speech_bubble()


func update_hp_bar() -> void:
	var hp = get_node("HP")
	if hp != null:
		hp.set_visible(true)
		%HPBar.value = int(float(hitpoints) * 100.0 / float(hitpoints_max))
		if %HPBar.value <= 25:
			%HPBar.set("tint_progress", Color("970000ff"))
		elif %HPBar.value <= 50:
			%HPBar.set("tint_progress", Color("ff8000"))
		else:
			%HPBar.set("tint_progress", Color("80ff00"))


func fx_take_damage() -> void:
	if fx_timer == null:
		get_node("Sprite2D").modulate = Color(Color.RED)
		fx_timer = Timer.new()
		add_child(fx_timer)
		fx_timer.wait_time = .1
		fx_timer.timeout.connect(fx_timeout)
		fx_timer.start()


func fx_timeout() -> void:
	if fx_timer != null:
		fx_timer.stop()
		remove_child(fx_timer)
		fx_timer.queue_free()
		get_node("Sprite2D").modulate = Color(Color.WHITE)


#TODO: Game over too specific to this level
func death() -> void:
	died.emit(exp_reward)
	var death_scene = death_packed.instantiate()
	death_scene.position = global_position + Vector2(0.0, -32.0)
	%Effects.add_child(death_scene)
	queue_free()
	player.game_over.emit(false)


func _on_hit_box_area_entered(area: Area2D) -> void:
	area.owner.take_damage(attack_damage)


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	nav_agent.velocity = safe_velocity


#TODO: Not just arrow
func fire() -> void:
	var arrow = arrow_packed.instantiate()
	arrow.unit_owner = self
	arrow.position = global_position + Vector2(0, -32)
	arrow.target_point = target.global_position + Vector2(0, -32)
	arrow.attack_type = GameData.get_mob_data_for("ARROW").get("ATTACK_TYPE")
	get_parent().add_child(arrow)
	pass


func _on_hurtbox_mouse_entered() -> void:
	get_node("Sprite2D").modulate = Color.YELLOW
	if speech_bubble != null and not speech_bubble.is_visible():
		speech_bubble.set_visible(true)
	if Input.is_action_pressed("shifty"):
		var cursor_arrow = load("res://assets/ui/pointers/02.png")
		Input.set_custom_mouse_cursor(cursor_arrow)


func _on_hurtbox_mouse_exited() -> void:
	get_node("Sprite2D").modulate = Color.WHITE
	if speech_bubble != null and speech_bubble.is_visible():
		speech_bubble.set_visible(false)
		
	var cursor_arrow = load("res://assets/ui/pointers/01.png")
	Input.set_custom_mouse_cursor(cursor_arrow)


func _on_hurtbox_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			get_node("PopupMenu").set_visible(not get_node("PopupMenu").is_visible())
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if Input.is_action_pressed("shifty"):
				player.select_npc(self)
				print("TODO: Popup npc menu")


#TODO: This is only for the archer, on this level
func get_popup_data(index: int) -> Dictionary:
	# 1 = 1, 2 = 3, 3 = 5
	var result = economy
	result.get("NEED").set("AMOUNT", result.get("NEED").get("AMOUNT_LEVEL")[index])
	result.get("HIRE").set("NUMBER_OF_ACTIONS", result.get("HIRE").set("NUMBER_OF_ACTIONS_LEVEL")[index])
	return result


func hire_me(_number_of_actions: int) -> Texture2D:
	hired = true
	number_of_actions = _number_of_actions
	return face_icon


#TODO: Remove from player's list
func fire_me() -> void:
	hired = false


#TODO
func within_range() -> bool:
	return false


# Inventory functions
func get_inventory_capacity_number_of_slots() -> int:
	return 5 # TODO Just for testing


func get_inventory_item(_index: int) -> Variant:
	return null


func get_inventory_name() -> String:
	var npc_data = GameData.get_npc_data_for(npc_type)
	return npc_data.get("NAME")


func get_inventory_icon() -> String:
	var npc_data = GameData.get_npc_data_for(npc_type)
	return npc_data.get("ICON")
