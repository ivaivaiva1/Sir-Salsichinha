extends Node

@export var level: int = 1

var experience: float = 0
var total_experience: float = 0
var experience_required: float = get_riquered_levelup_experience(level + 1)
var gem_value: float = get_gem_value(level)

func get_riquered_levelup_experience(level):
	return round(pow(level, 2) + (level * 10))

func get_gem_value(level):
	return round(pow(level, 1.6) + (level * 3)) 

func gain_experience(amount):
	total_experience += ((amount * gem_value) / 4) 
	experience += amount
	while experience >= experience_required:
		experience -= experience_required
		level_up()

func level_up():
	level += 1
	experience_required = get_riquered_levelup_experience(level + 1)
	gem_value = get_gem_value(level)
