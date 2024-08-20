extends Node

var player: Player 

func _ready():
	player = get_parent()
	LevelingController.connect("update_player_status", Callable(self, "change_status"))
	change_status(1)

func change_status(level: int): 
	match level:
		1:
			#player.sword_damage = 4
			player.sword_damage = 100
			player.sword_knockback_force = 150
			player.max_enemies_knockback = 1
			player.speed = 2
		2:
			#player.sword_damage = 8
			player.sword_knockback_force = 250
			player.max_enemies_knockback = 3
			player.speed = 2.5
		3:
			player.sword_knockback_force = 280
			player.max_enemies_knockback = 5
		4:
			#improve critical chance
			#improve critical damage
			pass
		5:
			player.sword_knockback_force = 310
			player.max_enemies_knockback = 7
		6:
			#improve critical chance
			#improve critical damage
			pass
		7:
			player.sword_damage = 12
			player.sword_knockback_force = 350
		8:
			player.sword_damage = 12
			player.sword_knockback_force = 350
		9:
			player.sword_damage = 12
			player.sword_knockback_force = 350
		10:
			#knockback_force 500
			#sword_damage 15
			#mov_speed 3
			pass





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
