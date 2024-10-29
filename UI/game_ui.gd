extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var gold_label: Label = %GoldLabel
@onready var kills_label: Label = %KillsLabel
@onready var level_label:  Label = %LevelLabel
@onready var experience_bar: ProgressBar = %ExperienceBar


func _process(delta):
	kills_label.text = str(GameManager.kills)
	timer_label.text = GameManager.time_elapsed_string
	level_label.text = str("Level: " , LevelingController.level)
	experience_bar.max_value = LevelingController.experience_required
	experience_bar.value = LevelingController.experience
