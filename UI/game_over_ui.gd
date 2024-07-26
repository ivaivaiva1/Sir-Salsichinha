class_name GameOverUI
extends CanvasLayer

@onready var time_label = %TimeLabel
@onready var monsters_label = %MonstersLabel

@export var restart_delay: float = 5

func _ready():
	time_label.text = GameManager.time_elapsed_string
	monsters_label.text = str(GameManager.kills)
