extends Node

var mob_spawner = MobSpawner
var function_list = self.get_script().get_script_method_list()
var scheduled_actions = []

func _ready():
	mob_spawner = get_parent()
	schedule_all_actions()

func schedule_all_actions():
	for function in function_list:
		if function.name.begins_with("min"):
			var minutes = int(function.name.substr(4, 2))
			var seconds = int(function.name.substr(12, 2))
			var time = (minutes * 60) + seconds
			schedule_action(time, function.name)

func _process(delta):
	if GameManager.is_game_over: return
	check_scheduled_actions(GameManager.time_elapsed)

func schedule_action(time: float, action_name: String):
	scheduled_actions.append({"time": time, "action": action_name})

func check_scheduled_actions(current_time: float):
	for action in scheduled_actions:
		if action["time"] <= current_time:
			call_action(action["action"])
			scheduled_actions.erase(action)

func call_action(action_name: String):
	if has_method(action_name):
		call(action_name)
	else:
		print("Method '%s' not found in SpawnController" % action_name)

func min_00_secs_02():
	mob_spawner.time_pawn = 0.2
	mob_spawner.time_pawn_blue = 0.8
	mob_spawner.time_pawn_red = 3
	mob_spawner.time_sheep = 5

#func min_00_secs_00():
	#mob_spawner.time_pawn = 0.7

#func min_01_secs_00():
	#mob_spawner.time_pawn = 0.2
	#mob_spawner.time_pawn_blue = 1
#
#func min_01_secs_30():
	#mob_spawner.time_pawn = 0.2
	#mob_spawner.time_pawn_blue = 0.8
	#mob_spawner.time_sheep = 5
#
#func min_02_secs_00():
	#mob_spawner.time_pawn = 0.2
	#mob_spawner.time_pawn_blue = 0.8
	#mob_spawner.time_pawn_red = 3
	#mob_spawner.time_sheep = 5
#
#func min_02_secs_30():
	#mob_spawner.time_pawn = 0.3
	#mob_spawner.time_pawn_blue = 0.6
	#mob_spawner.time_pawn_red = 2.5
	#mob_spawner.time_sheep = 3
#
#func min_03_secs_30():
	#mob_spawner.time_pawn = 0.3
	#mob_spawner.time_pawn_blue = 0.6
	#mob_spawner.time_pawn_red = 2
	#mob_spawner.time_sheep = 2
#
#func min_04_secs_30():
	#mob_spawner.time_pawn = 0.3
	#mob_spawner.time_pawn_blue = 0.6
	#mob_spawner.time_pawn_red = 2
	#mob_spawner.time_sheep = 1
#
#func min_05_secs_00():
	#mob_spawner.time_pawn = 0.3
	#mob_spawner.time_pawn_blue = 0.4
	#mob_spawner.time_pawn_red = 2
	#mob_spawner.time_sheep = 1
#
#func min_05_secs_30():
	#mob_spawner.time_pawn = 0.5
	#mob_spawner.time_pawn_blue = 0.4
	#mob_spawner.time_pawn_red = 1.8
	#mob_spawner.time_sheep = 1
#
#func min_06_secs_00():
	#mob_spawner.time_pawn = 1
	#mob_spawner.time_pawn_blue = 0.2
	#mob_spawner.time_pawn_red = 1.8
	#mob_spawner.time_sheep = 1
#
#func min_06_secs_30():
	#mob_spawner.time_pawn = 1.5
	#mob_spawner.time_pawn_blue = 0.2
	#mob_spawner.time_pawn_red = 1.5
	#mob_spawner.time_sheep = 1
#
#func min_07_secs_00():
	#mob_spawner.time_pawn = 2
	#mob_spawner.time_pawn_blue = 0.2
	#mob_spawner.time_pawn_red = 1
	#mob_spawner.time_sheep = 1
