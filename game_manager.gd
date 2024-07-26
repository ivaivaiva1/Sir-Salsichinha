extends Node

signal game_over
var player: Player
var player_position: Vector2
var kills: int = 0
var is_game_over: bool = false

var time_elapsed: float = 0
var time_elapsed_string: String

func _process(delta):
	# Update timer
	time_elapsed += delta
	var time_elapsed_seconds: int = floori(time_elapsed)
	var seconds: int = time_elapsed_seconds % 60
	var minutes: int = time_elapsed / 60
	time_elapsed_string = "%02d:%02d" % [minutes, seconds]

func end_game():
	if is_game_over: return
	is_game_over = true
	game_over.emit()
