extends Node

var sprite: Sprite2D

var input_vector: Vector2 = Vector2(0, 0)

var enemy: Enemy 

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("Sprite2D")

func _process(delta):
	if enemy.movement_type != "default_movement": return
	rotate_sprite()

func _physics_process(delta):
	if enemy.movement_type != "default_movement": return
	if GameManager.is_game_over: return
	set_move_direction()
	do_move()

func set_move_direction():
	var player_position = GameManager.player_position
	var difference = player_position - enemy.position
	input_vector = difference.normalized()

func do_move():  
	var move_direction
	if(!enemy.is_resting):
		move_direction = input_vector * enemy.speed * 100
	else:
		move_direction = input_vector * enemy.speed * 0
	if(enemy.actual_knockback.x > 0 or enemy.actual_knockback.y):
		enemy.velocity = enemy.actual_knockback
	else:
		enemy.velocity = move_direction
	enemy.move_and_slide()


func rotate_sprite():
	if(enemy.is_resting): return
	# Girar sprite
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true
