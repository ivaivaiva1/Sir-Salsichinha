class_name MobSpawner
extends Node2D

@onready var path_follow_2d: PathFollow2D = %PathFollow2D

#---------- Pawn ----------
@export var pawn: PackedScene
var time_pawn: float = 0
var cooldown_pawn: float = 0

#---------- Sheep ----------
@export var sheep: PackedScene
var time_sheep: float = 0
var cooldown_sheep: float = 0

#---------- Pawn Blue ----------
@export var pawn_blue: PackedScene
var time_pawn_blue: float = 0
var cooldown_pawn_blue: float = 0

#---------- Pawn Red ----------
@export var pawn_red: PackedScene
var time_pawn_red: float = 0
var cooldown_pawn_red: float = 0

#---------- Pawn Big ----------
@export var pawn_big: PackedScene
var time_pawn_big: float = 0
var cooldown_pawn_big: float = 0

#---------- Pawn Mini ----------
@export var pawn_mini: PackedScene
var time_pawn_mini: float = 0
var cooldown_pawn_mini: float = 0

#---------- Big Sheep ----------
@export var big_sheep: PackedScene
var time_big_sheep: float = 0
var cooldown_big_sheep: float = 0

#---------- Torch Yellow ----------
@export var torch_yellow: PackedScene
var time_torch_yellow: float = 0
var cooldown_torch_yellow: float = 0

#---------- Torch Blue ----------
@export var torch_blue: PackedScene
var time_torch_blue: float = 0
var cooldown_torch_blue: float = 0

#---------- Torch Red ----------
@export var torch_red: PackedScene
var time_torch_red: float = 0
var cooldown_torch_red: float = 0

func _process(delta):
	if GameManager.is_game_over: return
	spawnPawn(delta)
	spawnSheep(delta)
	spawnPawnBlue(delta)
	spawnPawnRed(delta)
	spawnPawnBig(delta)
	spawnPawnMini(delta)
	spawnBigSheep(delta)
	spawnTorchYellow(delta)
	spawnTorchBlue(delta)
	spawnTorchRed(delta)

func spawn_special_monster(monster: PackedScene):
	var spawn_point = return_valid_spawn_point()
	var monster_instance = monster.instantiate()
	monster_instance.global_position = spawn_point
	get_parent().get_parent().add_child(monster_instance)

func spawnPawn(delta: float):
	if time_pawn == 0: return
	cooldown_pawn -= delta
	if cooldown_pawn > 0: return
	cooldown_pawn = time_pawn
	var spawn_point = return_valid_spawn_point()
	var pawn_instance = pawn.instantiate()
	pawn_instance.global_position = spawn_point
	get_parent().get_parent().add_child(pawn_instance)

func spawnSheep(delta: float):
	if time_sheep == 0: return
	cooldown_sheep -= delta
	if cooldown_sheep > 0: return
	cooldown_sheep = time_sheep
	var spawn_point = return_valid_spawn_point()
	var sheep_instance = sheep.instantiate()
	sheep_instance.global_position = spawn_point
	get_parent().get_parent().add_child(sheep_instance)

func spawnPawnBlue(delta: float):
	if time_pawn_blue == 0: return
	cooldown_pawn_blue -= delta
	if cooldown_pawn_blue > 0: return
	cooldown_pawn_blue = time_pawn_blue
	var spawn_point = return_valid_spawn_point()
	var pawn_blue_instance = pawn_blue.instantiate()
	pawn_blue_instance.global_position = spawn_point
	get_parent().get_parent().add_child(pawn_blue_instance)

func spawnPawnRed(delta: float):
	if time_pawn_red == 0: return
	cooldown_pawn_red -= delta
	if cooldown_pawn_red > 0: return
	cooldown_pawn_red = time_pawn_red
	var spawn_point = return_valid_spawn_point()
	var pawn_red_instance = pawn_red.instantiate()
	pawn_red_instance.global_position = spawn_point
	get_parent().get_parent().add_child(pawn_red_instance)

func spawnPawnBig(delta: float):
	if time_pawn_big == 0: return
	cooldown_pawn_big -= delta
	if cooldown_pawn_big > 0: return
	cooldown_pawn_big = time_pawn_big
	var spawn_point = return_valid_spawn_point()
	var pawn_big_instance = pawn_big.instantiate()
	pawn_big_instance.global_position = spawn_point
	get_parent().get_parent().add_child(pawn_big_instance)

func spawnPawnMini(delta: float):
	if time_pawn_mini == 0: return
	cooldown_pawn_mini -= delta
	if cooldown_pawn_mini > 0: return
	cooldown_pawn_mini = time_pawn_mini
	var spawn_point = return_valid_spawn_point()
	var pawn_mini_instance = pawn_mini.instantiate()
	pawn_mini_instance.global_position = spawn_point
	get_parent().get_parent().add_child(pawn_mini_instance)

func spawnBigSheep(delta: float):
	if time_big_sheep == 0: return
	cooldown_big_sheep -= delta
	if cooldown_big_sheep > 0: return
	cooldown_big_sheep = time_big_sheep
	var spawn_point = return_valid_spawn_point()
	var big_sheep_instance = big_sheep.instantiate()
	big_sheep_instance.global_position = spawn_point
	get_parent().get_parent().add_child(big_sheep_instance)

func spawnTorchYellow(delta: float):
	if time_torch_yellow == 0: return
	cooldown_torch_yellow -= delta
	if cooldown_torch_yellow > 0: return
	cooldown_torch_yellow = time_torch_yellow
	var spawn_point = return_valid_spawn_point()
	var torch_yellow_instance = torch_yellow.instantiate()
	torch_yellow_instance.global_position = spawn_point
	get_parent().get_parent().add_child(torch_yellow_instance)

func spawnTorchBlue(delta: float):
	if time_torch_blue == 0: return
	cooldown_torch_blue -= delta
	if cooldown_torch_blue > 0: return
	cooldown_torch_blue = time_torch_blue
	var spawn_point = return_valid_spawn_point()
	var torch_blue_instance = torch_blue.instantiate()
	torch_blue_instance.global_position = spawn_point
	get_parent().get_parent().add_child(torch_blue_instance)

func spawnTorchRed(delta: float):
	if time_torch_red == 0: return
	cooldown_torch_red -= delta
	if cooldown_torch_red > 0: return
	cooldown_torch_red = time_torch_red
	var spawn_point = return_valid_spawn_point()
	var torch_red_instance = torch_red.instantiate()
	torch_red_instance.global_position = spawn_point
	get_parent().get_parent().add_child(torch_red_instance)

# -------------------- Get Spawn Point ------------------------

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
		if result.is_empty():
			point_is_safe = true
		else:
			point_is_safe = false
	return point

func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position
