extends Node

var enemy: Enemy

func _ready():
	enemy = get_parent()

func _process(delta):
	check_if_player_is_far()

func check_if_player_is_far():
	if abs(enemy.position.x - GameManager.player_position.x) > 2000 or abs(enemy.position.y - GameManager.player_position.y) > 2000:
		if abs(enemy.born_time - GameManager.time_elapsed) < 140:
			var new_position: Vector2 = get_new_position()
			enemy_reposition(new_position)
		else:
			enemy.queue_free()

func get_new_position() -> Vector2:
	var index = randi_range(0, 1)
	if index == 0:
		var multiplier = 1 if randf() < 0.5 else -1
		var xPos: float = GameManager.player_position.x + (700 * multiplier)
		var yPos: float = GameManager.player_position.y + (randf_range(-500, 500))
		return(Vector2(xPos, yPos))
	else:
		var multiplier = 1 if randf() < 0.5 else -1
		var xPos: float = GameManager.player_position.x + (randf_range(-700, 700))
		var yPos: float = GameManager.player_position.y + (500 * multiplier)
		return(Vector2(xPos, yPos))

func enemy_reposition(new_position: Vector2):
	enemy.position = new_position

