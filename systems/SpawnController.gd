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

# Exemplo de funções agendadas
func min_00_secs_00():
	mob_spawner.time_pawn = 2
	mob_spawner.time_sheep = 10
	mob_spawner.time_pawn_blue = 10
	#mob_spawner.time_torch_yellow = 10

func min_00_secs_40():
	mob_spawner.time_sheep = 10

func min_01_secs_00():
	mob_spawner.spawn_special_monster(mob_spawner.pawn_blue)

func min_30_secs_00():
	# Adicione a lógica aqui
	print("func")
