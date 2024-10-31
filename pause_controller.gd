extends Node

var is_paused: bool = false
@onready var pause_player = $"Pause Sound"

func _process(delta):
	if pause_player.playing: return
	if Input.is_action_just_pressed("pause"):
		change_pause_state()

func change_pause_state():
	if is_paused:
		is_paused = false
		get_tree().paused = false
		pause_player.play()
	else:
		is_paused = true
		get_tree().paused = true
		pause_player.play()
