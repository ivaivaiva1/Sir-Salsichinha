extends Node

@export var level: int = 1

var experience: float = 0
var total_experience: float = 0
var experience_required: float
var gem_value: float

signal update_player_status(float)

func _ready():
	experience_required = get_riquered_levelup_experience(level + 1)
	gem_value = get_gem_value(level)
	list_experience_riquered()

func list_experience_riquered():
	for i in range(1, 101):
		print("------------------ Nivel " , i , " ------------------")
		print("Experiencia necessaria: " , get_riquered_levelup_experience(i + 1))
		print("Inimigos necessarios: " , get_riquered_levelup_experience(i + 1) / (get_gem_value(i)))

func get_riquered_levelup_experience(level):
	if level >= 11:
		return round(pow(level, 3) + (level * 10))
	else:
		match level:
			2:
				return 5
			3:
				return 10
			4:
				return 15
			5:
				return 22
			6:
				return 30
			7:
				return 39
			8:
				return 49
			9:
				return 62
			10:
				return 75

func get_gem_value(level):
	if level >= 10:
		return round((pow(level, 1.6) + (level * 3)) / 4) 
	else:
		return 1

func gain_experience(amount):
	var gained_experience = amount * gem_value
	total_experience += gained_experience
	experience += gained_experience
	while experience >= experience_required:
		experience -= experience_required
		level_up()

func level_up():
	level += 1
	experience_required = get_riquered_levelup_experience(level + 1)
	gem_value = get_gem_value(level)
	emit_signal("update_player_status", level)
