extends CharacterBody2D

signal game_over(victorious: bool)
signal update_hp_bar(hp_bar_value: int)

enum State {
	IDLE,
	RUN,
	ATTACK,
	DEAD
}

const ZOOM_FACTOR = 1.25
var state: State = State.IDLE
var move_direction: Vector2 = Vector2(0,0)
var attack_speed: float
var hitpoints_max: float
var fx_timer: Timer
var current_selected_npc: CharacterBody2D
var next_double_hit: bool = true
var next_double_hit_timer: Timer
var zoom_increment: float = 0.05
var zoom_target: float = 1.0
var zoom_timer: Timer
var stupid_timer: Timer
var stupid_level: int = 0
var stupid_count: int = 0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var hud: Control = get_tree().get_first_node_in_group("hud")

func _ready() -> void:
	hitpoints_max = PlayerData.get_max_hp()
	animation_tree.set_active(true)
	calculate_stats()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Mouse event: ", event)
		if Input.is_action_pressed("shifty"):
			print("TODO: Mark target ground")
		else:
			attack(Input.is_action_pressed("ctrl"))
	#elif event.b


func _physics_process(_delta: float) -> void:
	if state != State.ATTACK:
		movement_loop()


func _process(delta: float) -> void:
	#Update derived stats using recovery
	if PlayerData.get_current_hp() < PlayerData.get_max_hp():
		var new_value = PlayerData.get_current_hp() + (GameData.get_recovery_per_level("HP", PlayerData.get_player_level()) * delta)
		if new_value > PlayerData.get_max_hp():
			PlayerData.set_current_hp(PlayerData.get_max_hp())
		else:
			PlayerData.set_current_hp(new_value)
		update_ui_elements()


#TODO: Move to game_scene
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		var resource_props = get_tree().get_nodes_in_group("resource_props")
		for resource_prop in resource_props:
			if resource_prop.in_range:
				resource_prop.death()
	elif event.is_action_pressed("help"):
		stupid()


func calculate_stats():
	attack_speed = Equations.calculate_attack_speed()
	var time_factor: float = Equations.BASE_ATTACK_SPEED / attack_speed
	animation_tree.set("parameters/attack/TimeScale/scale", time_factor)
	print("Attack speed: ", attack_speed)


func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	move_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	var motion: Vector2 = move_direction.normalized() * PlayerData.get_current_speed()
	set_velocity(motion)
	move_and_slide()

	if state == State.IDLE or State.RUN:
		if move_direction.x < -0.01:
			$Sprite2D.flip_h = true
		elif move_direction.x > 0.01:
			$Sprite2D.flip_h = false

	if motion != Vector2.ZERO and state == State.IDLE:
		state = State.RUN
		update_animation()
	elif motion == Vector2.ZERO and state == State.RUN:
		state = State.IDLE
		update_animation()


func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.RUN:
			animation_playback.travel("run")
		State.ATTACK:
			animation_playback.travel("attack")
		State.DEAD:
			pass


func attack(double_hit: bool) -> void:
	if state == State.ATTACK:
		return
	state = State.ATTACK
	
	var which_attack = "attack"
	var speed_factor = 1
	if double_hit and next_double_hit:
		which_attack = "attack_double"
		speed_factor = 2
		double_hit_start()
		
	var mouse_pos: Vector2 = get_global_mouse_position()
	var attack_dir: Vector2 = (mouse_pos - global_position).normalized()
	$Sprite2D.flip_h = attack_dir.x < 0 and abs(attack_dir.x) >= abs(attack_dir.y)
	animation_tree.set("parameters/" + which_attack + "/BlendSpace2D/blend_position", attack_dir)
	update_animation()
	
	await get_tree().create_timer(attack_speed * speed_factor).timeout
	state = State.IDLE


#TODO: Defence + Armour
func take_damage(damage_taken: int, _damage_type: Array) -> void:
	fx_take_damage()
	PlayerData.dec_current_hp(damage_taken)
	update_ui_elements()
	if PlayerData.get_current_hp() <= 0:
		death()


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


func double_hit_start() -> void:
	if next_double_hit_timer == null:
		next_double_hit = false
		next_double_hit_timer = Timer.new()
		add_child(next_double_hit_timer)
		next_double_hit_timer.wait_time = Equations.calculate_double_attack_wait()
		next_double_hit_timer.timeout.connect(next_double_hit_timer_timeout)
		next_double_hit_timer.start()


func next_double_hit_timer_timeout() -> void:
	if next_double_hit_timer != null:
		next_double_hit_timer.stop()
		remove_child(next_double_hit_timer)
		next_double_hit = true


func update_ui_elements() -> void:
	update_hp_bar.emit((PlayerData.get_current_hp() * 100) / PlayerData.get_max_hp())


func death() -> void:
	game_over.emit(false)


func _on_hit_box_area_entered(area: Area2D) -> void:
	area.owner.take_damage(PlayerData.get_current_attack(), ["SHARP"])


#┌───────────┐
#│ NPC Stuff │
#└───────────┘
func select_npc(_npc: CharacterBody2D) -> void:
	current_selected_npc = _npc

#TODO: Add to PlayerData?
func add_selected_npc(which: Node2D, face_icon: Texture2D) -> void:
	hud.add_selected_npc(which, face_icon)


#TODO: Add to PlayerData?
func change_hire_selection(hire_slot: Control) -> void:
	hire_slot.set_selected(true)


#TODO: UI for no selected NPC?
func select_target(_target: CharacterBody2D) -> void:
	var which = hud.get_selected_npc()
	if which != null:
		which.target = _target


#┌───────────┐
#│ Inventory │
#└───────────┘
## Call this one not the PlayerData one!
func add_to_inventory(_amount: int, _template_id: String) -> void:
	if _template_id == "COIN":
		PlayerData.add_coins(_amount)
	else:
		var amount = _amount
		while amount > 0:
			var result = PlayerData.add_to_inventory(_template_id)
			if result < 1:
				break
			amount -= 1
	GameData.inventory_changed.emit()


## Call this one not the PlayerData one!
func remove_from_inventory(_amount: int, _template_id: String) -> void:
	if _template_id == "COIN":
		PlayerData.remove_coins(_amount)
		#hud.update_hud_coins()
	else:
		var _new_amount = PlayerData.remove_from_inventory(_amount, _template_id)
		#hud.update_hud_inventory()
	GameData.inventory_changed.emit()


## Call this one not the PlayerData one!
func get_inventory_amount(_template_id: String) -> int:
	if _template_id == "COIN":
		return PlayerData.get_coins()
	else:
		return PlayerData.get_inventory_amount(_template_id)


#┌───────────────┐
#│ Derived Stats │
#└───────────────┘
func increase_derived(which: String, amount: int) -> void:
	var result: float = 0
	match which:
		"hp":
			result = PlayerData.inc_current_hp(amount)
		"atk":
			result = PlayerData.inc_current_attack(amount)
		"def":
			#result = PlayerData.inc_current_defence(amount)
			pass
		"acc":
			pass
		"cc":
			pass
		"eva":
			pass
		"res":
			pass
		"spd":
			result = PlayerData.inc_current_speed(amount)

	for slot in hud.get_node("Stats").get_children():
		if slot.to_lower() == which:
			slot.set_amount(result)
			break # out of loop


func set_declutter(_declutter) -> void:
	if _declutter:
		zoom_target = ZOOM_FACTOR
	else:
		zoom_target = 1.0
	if zoom_timer == null:
		zoom_timer = Timer.new()
		add_child(zoom_timer)
		zoom_timer.wait_time = zoom_increment
		zoom_timer.timeout.connect(zoom_timeout)
		zoom_timer.start()
	hud.set_declutter(_declutter)


func zoom_timeout() -> void:
	if zoom_timer != null:
		var zoom_x = get_node("PlayerCamera").get_zoom().x
		var zoom_delta = zoom_x - zoom_target
		if zoom_delta > 0.025:
			zoom_x -= 0.025
		elif zoom_delta < -0.025:
			zoom_x += 0.025
		else: 
			zoom_x = zoom_target
		get_node("PlayerCamera").set_zoom(Vector2(zoom_x, zoom_x))
		if zoom_x == zoom_target:
			zoom_timer.stop()
			remove_child(zoom_timer)
			zoom_timer.queue_free()


func stupid() -> void:
	if stupid_timer == null:
		get_node("Stupid").set_visible(true)
		hud.get_node("FKeys").set_visible(true)
		stupid_count += 1
		stupid_timer = Timer.new()
		add_child(stupid_timer)
		stupid_timer.wait_time = 2
		stupid_timer.timeout.connect(stupid_timeout)
		stupid_timer.start()


func stupid_timeout() -> void:	
	hud.get_node("FKeys").set_visible(false)
	get_node("Stupid/Sprite2D").frame = 11
	if stupid_count == 3:
		var explosion_packed: PackedScene = load("res://scenes/entities/npc/mobs/explosion.tscn")
		var explosion = explosion_packed.instantiate()
		explosion.position = global_position
		explosion.attack_damage = 1000
		explosion.aoe_radius = 512
		explosion.scale_me = Vector2(10.0, 10.0)
		get_parent().add_child(explosion)
	if stupid_timer != null:
		if stupid_level == 0:
			get_node("Stupid").set_visible(false)
			hud.get_node("GodResponse").set_visible(true)
			stupid_level += 1
		elif stupid_level == 1:
			hud.get_node("GodResponse").set_visible(false)
			hud.get_node("GodResponse/Label").set_text("(*¬_¬)")
			hud.get_node("DevilResponse").set_visible(true)
			stupid_level += 1
		elif stupid_level == 2:
			hud.get_node("DevilResponse").set_visible(false)
			hud.get_node("DevilResponse/Label").set_text("(*¬_¬)")
			stupid_timer.stop()
			remove_child(stupid_timer)
			stupid_timer.queue_free()
			stupid_level = 0
