extends Node2D

@export var damage_amount: int = 1

@export var knockback_force: int = 1

@onready var area2d: Area2D = $Area2D

func deal_damage():
	var bodies = area2d.get_overlapping_bodies()
	for body in bodies:
		if body is Enemy:
			var enemy: Enemy = body
			var direction = calculate_knockback_direction(enemy)
			var damage_id = randi_range(0, 1000000)
			#enemy.get_hited(damage_amount, direction, knockback_force, damage_id)

# Função que calcula a direção do knockback para um inimigo
func calculate_knockback_direction(enemy: Enemy) -> Vector2:
	return (enemy.global_position - global_position).normalized()
