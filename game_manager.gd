extends Node

signal game_over
var player: Player
var player_position: Vector2
var kills: int = 0
var is_game_over: bool = false

var time_elapsed: float = 0
var time_elapsed_string: String

var enemies_hited: int = 0

func _process(delta):
	# Update timer
	time_elapsed += delta
	var time_elapsed_seconds: int = floori(time_elapsed)
	var seconds: int = time_elapsed_seconds % 60
	var minutes: int = time_elapsed / 60
	time_elapsed_string = "%02d:%02d" % [minutes, seconds]
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		time_elapsed = 0
		Engine.time_scale = 1

func end_game():
	if is_game_over: return
	is_game_over = true
	game_over.emit()

func im_hited():
	enemies_hited += 1
