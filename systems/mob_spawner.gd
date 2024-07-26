extends Node2D

@export var creatures: Array[PackedScene]
@export var mobs_per_minute: float = 60

@onready var path_follow_2d: PathFollow2D = %PathFollow2D
var cooldown: float = 0

func _process(delta):
	if GameManager.is_game_over: return
	# Checa o cooldown
	cooldown -= delta
	if cooldown > 0: return
	
	# Seta o cooldown
	var interval = 60 / mobs_per_minute
	cooldown = interval
	
	# Cria um spawn point valído
	var spawn_point = return_valid_spawn_point()
	
	# Instancia o monstro
	var index: int
	var random = randi_range(0, 100)
	if random < 10:
		index = 1
	else:
		index = 0
	#var index = 0
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.global_position = spawn_point
	get_parent().get_parent().add_child(creature)

func return_valid_spawn_point() -> Vector2:
	var point_is_safe: bool = false
	var loop_break: int = 0
	var point: Vector2
	while not point_is_safe:
		loop_break += 1
		point = get_point()
		var world_state = get_world_2d().direct_space_state
		var parameters = PhysicsPointQueryParameters2D.new()
		parameters.position = point
		var result: Array = world_state.intersect_point(parameters, 1)
		if loop_break > 1000: 
			print("Ponto n encontrado")
			break
		if result.is_empty():
			point_is_safe = true
		else:
			point_is_safe = false
	return point



func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position
