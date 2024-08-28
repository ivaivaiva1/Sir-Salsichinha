extends Node

@export var drag_factor: float

var sprite: Sprite2D 
var direction: Vector2
var _current_velocity := Vector2.ZERO
var enemy: Enemy

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("Sprite2D")

func _process(delta: float):	
	if enemy.movement_type != "drag_movement": return
	# Atualiza o drag factor para se aproximar do valor alvo
	set_move_direction()
	rotate_sprite()

func rotate_sprite():
	if(enemy.is_resting): return
	if sprite == null: return
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true

func _physics_process(delta: float) -> void:
	if enemy.movement_type != "drag_movement": return
	if(enemy.actual_knockback.x > 0 or enemy.actual_knockback.y):
		enemy.velocity = enemy.actual_knockback
		enemy.move_and_slide()
	else:
		if(enemy.is_resting): return
		var desired_velocity: Vector2 = direction * (enemy.speed * 100)
		
		# Calcular a mudança na velocidade corrigida pelo drag_factor
		var corrected_change = (desired_velocity - _current_velocity) * drag_factor / delta
		
		_current_velocity += corrected_change * delta
		enemy.position += _current_velocity * delta

func set_move_direction():
	var difference = GameManager.player_position - enemy.position
	direction = difference.normalized()
