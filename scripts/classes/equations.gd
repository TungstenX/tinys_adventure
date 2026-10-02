class_name Equations
extends Node

const BASE_ATTACK_SPEED: float = 0.6
const BASE_DOUBLE_ATTACK_WAIT: float = 20

static func calculate_attack_speed() -> float:
	var attack_speed: float = BASE_ATTACK_SPEED * (1 - 0.15 * (PlayerData.get_player_level() - 1))
	return attack_speed


static func calculate_double_attack_wait() -> float:
	var attack_wait: float = BASE_DOUBLE_ATTACK_WAIT * (1 - 0.15 * (PlayerData.get_player_level() - 1))
	return attack_wait
