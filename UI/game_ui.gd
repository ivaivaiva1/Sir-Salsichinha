extends CanvasLayer

@onready var timer_label: Label = $TimerLabel
@onready var gold_label: Label = %GoldLabel
@onready var kills_label: Label = %KillsLabel

func _process(delta):
	kills_label.text = str(GameManager.kills)
	timer_label.text = GameManager.time_elapsed_string
