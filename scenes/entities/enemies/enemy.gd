extends CharacterBody2D

signal died(exp: int)

enum State {
	IDLE,
	CHASE,
	RETURN,
	ATTACK,
	DEAD
}

enum MobType {
	RED_UNIT,
	THIEF,
	SKULL,
	BOMB_FISH,
	BEAR
}

enum MobBehaviour {
	NORMAL,
	CANT_MOVE,
	SLEEP
}

enum AttackStyle {
	MELEE,
	RANGE
}

enum ProjectileType {
	ARROW,
	BOLT,
	BOMB
}

@export_category("Related Scenes")
@export var death_packed: PackedScene
@export_category("Mob Type")
@export var mob_type: MobType = MobType.RED_UNIT
@export var mob_attack_style: AttackStyle = AttackStyle.MELEE
@export var mob_level: int = 1
@export_category("Mob Behaviour")
@export var mob_behaviour: MobBehaviour = MobBehaviour.NORMAL
@export var spawn_skull: bool = true
@export_category("Mob Projectile")
@export var projectile_packed: PackedScene

var state: State = State.IDLE
# Stats
var hitpoints: int = 180
var attack_damage: int = 10
var defence: int = 0
var hitpoints_max: int
var speed: int = 128
var attack_speed: float = 1.0
var reload_delay = 0.0
var agro_range: float = 256.0
var attack_range: float = 80.0
var exp_reward: int = 600

var fx_timer: Timer
var speech_timer: Timer
var reload_timer: Timer

@onready var spawn_point: Vector2 = global_position
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	animation_tree.set_active(true)
	var mob_data = GameData.get_mob_data_for(MobType.keys().get(mob_type))
	speed = mob_data.get("SPEED").get(mob_level)
	attack_damage = mob_data.get("ATTACK_DAMAGE").get(mob_level)
	attack_speed = mob_data.get("ATTACK_SPEED").get(mob_level)
	if mob_data.has("RELOAD_DELAY"):
		reload_delay = mob_data.get("RELOAD_DELAY").get(mob_level)
	hitpoints = mob_data.get("HITPOINTS").get(mob_level)
	hitpoints_max = hitpoints
	agro_range = mob_data.get("AGRO_RANGE").get(mob_level)
	attack_range = mob_data.get("ATTACK_RANGE").get(mob_level)
	exp_reward = mob_data.get("EXP_REWARD").get(mob_level)
	%SpeechBubble.hp = str(hitpoints)
	%SpeechBubble.atk = str(attack_damage)
	%SpeechBubble.def = str(defence)
	%SpeechBubble.update_text()
	print("Mob: ", get_node(".").get_name())
	if mob_type == GameData.MobType.SKULL:
		death_packed = load("res://scenes/effects/dust.tscn")
		spawn_skull = false


func _physics_process(_delta: float) -> void:
	if state == State.DEAD:
		return
	if state == State.ATTACK:
		return
	if distance_to_player() <= attack_range:
		state = State.ATTACK
		attack()
	elif distance_to_player() <= agro_range:
		start_agro()
		state = State.CHASE
		move()
	elif global_position.distance_to(spawn_point) > 32:
		end_agro()
		state = State.RETURN
		move()
	elif state != State.IDLE:
		state = State.IDLE
		update_animation()


func distance_to_player() -> float:
	return global_position.distance_to(player.global_position)


func move() -> void:
	if mob_behaviour == MobBehaviour.CANT_MOVE:
		return
	if state == State.CHASE:
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
	
	if state == State.IDLE or State.CHASE:
		if velocity.x < -0.01:
			$Sprite2D.flip_h = true
		elif velocity.x > 0.01:
			$Sprite2D.flip_h = false
			
	update_animation()


func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.CHASE:
			animation_playback.travel("run")
		State.RETURN:
			animation_playback.travel("run")
		State.ATTACK:
			animation_playback.travel("attack")
		State.DEAD:
			pass


func start_agro() -> void:
	if state != State.CHASE:
		player.set_declutter(true)
		
		if speech_timer != null:
			speech_timer = Timer.new()
			add_child(speech_timer)
			speech_timer.wait_time = .5
			speech_timer.timeout.connect(end_agro)
			speech_timer.start()


func end_agro() -> void:
	if speech_timer != null:
		speech_timer.stop()
		speech_timer.queue_free()
	player.set_declutter(false)
	#if %SpeechBubble.is_visible():
		#%SpeechBubble.set_visible(false)


func attack() -> void:
	var player_pos: Vector2 = player.global_position
	var attack_dir: Vector2 = (player_pos - global_position).normalized()
	#TODO: 
	$Sprite2D.flip_h = attack_dir.x < 0 # and abs(attack_dir.x) >= abs(attack_dir.y)
	animation_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir)
	update_animation()
	
	await get_tree().create_timer(attack_speed).timeout
	if reload_delay > 0.0:
		start_reload_timer()
	else:
		state = State.IDLE


func spawn_projectile() -> void:
	var projectile = projectile_packed.instantiate()
	projectile.unit_owner = self
	projectile.target_point = player.global_position
	projectile.position = global_position + Vector2(0, -32)
	if mob_type == MobType.BOMB_FISH:
		projectile.type = ProjectileType.BOMB
	get_parent().add_child(projectile)
	
	
func take_damage(damage_taken: int) -> void:
	fx_take_damage()
	hitpoints -= damage_taken
	%SpeechBubble.hp = str(hitpoints)
	%SpeechBubble.update_text()
	update_hp_bar()
	
	if hitpoints <= 0:
		death()


func update_hp_bar() -> void:
	get_node("HP").set_visible(true)
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


func start_reload_timer() -> void:
	if reload_timer == null:
		reload_timer = Timer.new()
		add_child(reload_timer)
		reload_timer.wait_time = reload_delay
		reload_timer.timeout.connect(reload_timeout)
		reload_timer.start()


func reload_timeout() -> void:
	if reload_timer != null:
		reload_timer.stop()
		remove_child(reload_timer)
		reload_timer.queue_free()
		state = State.IDLE


func death() -> void:
	player.set_declutter(false)
	died.emit(exp_reward)
	#if mob_type != MobType.SKULL:
	var death_scene = death_packed.instantiate()
	death_scene.position = global_position + Vector2(0.0, -32.0)
	if "spawn_skull" in death_scene:
		death_scene.spawn_skull = spawn_skull
	if spawn_skull and "node" in death_scene:
		death_scene.node = get_parent()
	get_node("../../Effects").add_child(death_scene)
	queue_free()
	


func _on_hit_box_area_entered(area: Area2D) -> void:
	area.owner.take_damage(attack_damage)


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	nav_agent.velocity = safe_velocity


func fire() -> void:
	print("TODO: Enemy fire")
	pass


func _on_hurtbox_mouse_entered() -> void:
	if state != State.ATTACK:
		%SpeechBubble.set_visible(true)


func _on_hurtbox_mouse_exited() -> void:
	%SpeechBubble.set_visible(false)


func _on_hurtbox_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			pass
			#get_node("PopupMenu").set_visible(not get_node("PopupMenu").is_visible())
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if Input.is_action_pressed("shifty"):
				player.select_target(self)
