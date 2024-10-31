extends Node
class_name Dash_Hit

var enemy: Enemy

#var ghost_scene = preload("res://enemies/Torch_Ghost/DashGhostScene.tscn")
var ghost: Sprite2D
var can_dash: bool = true
var spawn_ghost_cooldown: float = 0
var player_is_near: bool = false
var is_following_player: bool = false

func _ready():
	enemy = get_parent()

func _process(delta):
	if spawn_ghost_cooldown > 0:
		spawn_ghost_cooldown -= delta
	
	if player_is_near:
		if not enemy.is_resting:
			if not is_following_player:
				is_following_player = true
				enemy.speed = 5
				enemy.movement_type = "default_movement"
				

	else:
		enemy.speed = 2
		enemy.movement_type = "drag_movement"
	
	if is_following_player:
		if spawn_ghost_cooldown <= 0:
			spawn_ghost_cooldown = 0.05
			enemy.animation_player.set_speed_scale(1.5)
			instance_ghost()
		else:
			enemy.animation_player.set_speed_scale(1.0)

func instance_ghost():
#	ghost = ghost_scene.instantiate()
	#get_parent().get_parent().add_child(ghost)
	var sprite = enemy.sprite2d
	if not sprite: return
	ghost.global_position = enemy.global_position
	ghost.texture = sprite.texture
	ghost.vframes = sprite.vframes
	ghost.hframes = sprite.hframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h

func enemy_is_attacking():
	is_following_player = false

func _on_area_to_dash_area_entered(area):
	if area.is_in_group("player"):
		player_is_near = true

func _on_area_to_dash_area_exited(area):
	if area.is_in_group("player"):
		player_is_near = false
