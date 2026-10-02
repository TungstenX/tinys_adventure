extends CharacterBody2D

enum State {
	FLYING,
	HIT,
	LANDED,
	DEAD
}

enum ProjectileType {
	ARROW,
	BOLT,
	BOMB
}

enum ProjectileDir {
	RIGHT, RIGHT_UP, UP, LEFT_UP, LEFT, LEFT_DOWN, DOWN, RIGHT_DOWN
}

var speed: int = 256
var state: State = State.FLYING
var type: ProjectileType = ProjectileType.ARROW
var target_point: Vector2
var attack_damage: int = 200
var unit_owner

var angle: float = 0.0
var projectile_dir: ProjectileDir = ProjectileDir.RIGHT
var explosion_packed: PackedScene
var arrow_hit_packed: PackedScene

const RIGHT_DIR: Vector2 = Vector2(-PI/8.0, PI/8.0)
const RIGHT_UP_DIR: Vector2 = Vector2((-PI/4.0) + (-PI/8.0), -PI/8.0)
const UP_DIR: Vector2 = Vector2((-PI/2.0) + (-PI/8.0), (-PI/4.0) + (-PI/8.0))
const LEFT_UP_DIR: Vector2 = Vector2((-PI*3.0/4.0) + (-PI/8.0), (-PI/2.0) + (-PI/8.0))
const LEFT_DIR_1: Vector2 = Vector2(-PI, (-PI*3.0/4.0) + (-PI/8.0))
const LEFT_DIR_2: Vector2 = Vector2(PI, (PI*3.0/4.0) + (PI/8.0))
const LEFT_DOWN_DIR: Vector2 = Vector2((PI*3.0/4.0) + (PI/8.0), (PI/2.0) + (PI/8.0))
const DOWN_DIR: Vector2 = Vector2((PI/2.0) + (PI/8.0), (PI/4.0) + (PI/8.0))
const RIGHT_DOWN_DIR: Vector2 = Vector2((PI/4.0) + (PI/8.0), PI/8.0)

@onready var animation_player: AnimationPlayer = $AnimationPlayer


# TODO: 
# attack_damage from json
# bomb needs to roll a bit when landed
# arrow and bomb needs parabolic flight
func _ready() -> void:
	if type == ProjectileType.ARROW:
		arrow_hit_packed = load("res://scenes/entities/projectile/arrow_hit.tscn")
	elif type == ProjectileType.BOMB:
		animation_player.play("fly")
		explosion_packed = load("res://scenes/entities/npc/mobs/explosion.tscn")
		attack_damage = 20


func _physics_process(_delta: float) -> void:
	if state == State.FLYING:
		move()
	elif state == State.LANDED:
		if type == ProjectileType.BOMB:
			roll()
	else:
		pass


func move() -> void:
	if state == State.DEAD:
		return
	if global_position.distance_to(target_point) < 5.0 or state == State.HIT or state == State.LANDED:
		state = State.LANDED
		end_flight()
		return
		
	var dir = global_position.direction_to(target_point)
	velocity = dir * speed
	angle = global_position.angle_to_point(target_point)
	projectile_dir = get_dir(angle)
	move_and_slide()


func roll() -> void:
	pass


func get_dir(ang: float) -> ProjectileDir:
	if ang > RIGHT_DIR.x and ang <= RIGHT_DIR.y:
		if type == ProjectileType.ARROW:
			get_node(".").rotation = 0.0
		else:
			get_node("Sprite2D").flip_h = false
		return ProjectileDir.RIGHT
	elif ang > RIGHT_UP_DIR.x and ang <= RIGHT_UP_DIR.y:
		if type == ProjectileType.ARROW:
			get_node(".").rotation = -45.0
		else:
			get_node("Sprite2D").flip_h = false
		return ProjectileDir.RIGHT_UP
	elif ang > UP_DIR.x and ang <= UP_DIR.y:
		if type == ProjectileType.ARROW:
			get_node(".").rotation = -90.0
		else:
			get_node("Sprite2D").flip_h = false
		return ProjectileDir.UP
	elif ang > LEFT_UP_DIR.x and ang <= LEFT_UP_DIR.y:
		if type == ProjectileType.ARROW:
			get_node(".").rotation = -135.0
		else:
			get_node("Sprite2D").flip_h = true
		return ProjectileDir.LEFT_UP
	elif ang > LEFT_DIR_1.x and ang <= LEFT_DIR_1.y:
		if type == ProjectileType.ARROW:
			get_node(".").rotation = 180.0
		else:
			get_node("Sprite2D").flip_h = true
		return ProjectileDir.LEFT
	elif ang <= LEFT_DIR_2.x and ang > LEFT_DIR_1.y:
		if type == ProjectileType.ARROW:
			get_node(".").rotation = 180.0
		else:
			get_node("Sprite2D").flip_h = true
		return ProjectileDir.LEFT
	elif ang <= LEFT_DOWN_DIR.x and ang > LEFT_DOWN_DIR.y:
		if type == ProjectileType.ARROW:
			get_node(".").rotation = 135.0
		else:
			get_node("Sprite2D").flip_h = true
		return ProjectileDir.LEFT_DOWN
	elif ang <= DOWN_DIR.x and ang > DOWN_DIR.y:
		if type == ProjectileType.ARROW:
			get_node(".").rotation = 90.0
		else:
			get_node("Sprite2D").flip_h = true
		return ProjectileDir.DOWN
	elif ang <= RIGHT_DOWN_DIR.x and ang > RIGHT_DOWN_DIR.y:
		if type == ProjectileType.ARROW:
			get_node(".").rotation = 45.0
		else:
			get_node("Sprite2D").flip_h = false
		return ProjectileDir.RIGHT_DOWN
	if type == ProjectileType.ARROW:
		get_node(".").rotation = 0.0
	else:
		get_node("Sprite2D").flip_h = false
	return ProjectileDir.RIGHT


func _on_hitbox_area_entered(area: Area2D) -> void:
	if unit_owner != area.owner:
		area.owner.take_damage(attack_damage)
		state = State.HIT
		end_flight()


func take_damage(_damage: float) -> void:
	if type == ProjectileType.BOMB:
		end_flight()


func end_flight() -> void:
	if state == State.DEAD:
		return
	var hit = true
	if type == ProjectileType.ARROW:
		if state == State.HIT:
			if projectile_dir == ProjectileDir.RIGHT or ProjectileDir.RIGHT_UP or ProjectileDir.RIGHT_DOWN:
				angle = 45.0
			else:
				angle = 135.0
		else:
			hit = false
		state = State.DEAD
		
		var arrow_hit = arrow_hit_packed.instantiate()
		arrow_hit.position = position
		arrow_hit.hit = hit
		arrow_hit.dir = angle
		get_parent().add_child(arrow_hit)
		queue_free()
	elif type == ProjectileType.BOMB:
		animation_player.play("land")
		await get_tree().create_timer(0.4).timeout
		queue_free()
		# TODO: dud
		var explosion = explosion_packed.instantiate()
		explosion.position = global_position
		#TODO from json file
		explosion.attack_damage = attack_damage * 10
		explosion.aoe_radius = 100
		get_parent().add_child(explosion)
		print("Apply area damage")
		
