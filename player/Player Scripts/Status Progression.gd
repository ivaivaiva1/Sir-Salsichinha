extends Node

var player: Player 

func _ready():
	player = get_parent()
	LevelingController.connect("update_player_status", Callable(self, "change_status"))
	change_status(1)

func change_status(level: int): 
	match level:
		1:
			player.sword_damage = 4
			player.sword_knockback_force = 150
			player.max_enemies_knockback = 1
			player.speed = 2
		2:
			player.sword_damage = 8
			player.sword_knockback_force = 250
			player.max_enemies_knockback = 5
			player.speed = 2.5
		3:
			player.sword_knockback_force = 280
		4:
			player.sword_knockback_force = 310
		5:
			player.sword_damage = 12
			player.sword_knockback_force = 350




#level 1
#sword damage 5
#sword kockback 300
#max health 1000
#max enemies knockbacked 5




#do jeito q esta talvez nivel 15, nerfar um pouquinho:
#sword damage 23
#sword knockback 700
#max health 1000
#max enemies knockbacked 100
#auto knockback 500
