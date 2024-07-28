extends Node

class Damage_Instance:
	var force_id: int
	var force_damage: float
	var force_power: float
	var max_hited_enemies: int
	var force_decay_time: float 

var all_game_damages: Array[Damage_Instance] = []

func create_damage_instance(force_damage: float, force_power: float, max_hited_enemies: int, force_decay_time: float = 0.35) -> Damage_Instance:
	var damage_instance: Damage_Instance = Damage_Instance.new()
	damage_instance.force_id = randi_range(0, 1000000)
	damage_instance.force_damage = force_damage
	damage_instance.force_power = force_power
	damage_instance.max_hited_enemies = max_hited_enemies
	damage_instance.force_decay_time = force_decay_time
	all_game_damages.append(damage_instance)
	return damage_instance

func check_max_hited_enemies(damage_instance = Damage_Instance) -> bool:
	var damage_is_enabled: bool
	damage_instance.max_hited_enemies -= 1
	if damage_instance.max_hited_enemies < 0:
		return false
	else:
		return true
