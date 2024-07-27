extends Node

class Damage_Instance:
	var force_id: int
	var force_damage: float
	var force_power: float
	var force_decay_time: float 

var all_game_damages: Array[Damage_Instance] = []

func create_damage_instance(force_damage: float, force_power: float, force_decay_time: float = 0.35):
	var damage_instance: Damage_Instance = Damage_Instance.new()
	damage_instance.force_id = randi_range(0, 1000000)
	damage_instance.force_damage = force_damage
	damage_instance.force_power = force_power
	damage_instance.force_decay_time = force_decay_time
	all_game_damages.append(damage_instance)
