extends Node

var player: Player

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sword_area_left: Area2D = %SwordAreaLeft
@onready var sword_area_right: Area2D = %SwordAreaRight
@onready var sword_area_up: Area2D = %SwordAreaUp
@onready var sword_area_down: Area2D = %SwordAreaDown

var attack_cast: float = 0

func _ready():
	player = get_parent()

func _process(delta):
	update_attack_cast(delta)
	if Input.is_action_just_pressed("attack"):
		attack()

# Inicia o ataque
func attack():
	if player.is_attacking:
		return
	
	#var choseAttack = randi_range(0, 1)
	#if choseAttack == 0:
	#	animation_player.play("attack_side_1")
	#elif choseAttack == 1:
	#	animation_player.play("attack_side_2")
	player.can_flip = false
	if player.input_vector.y > 0:
		animation_player.play("attack_down_1")
	elif player.input_vector.y < 0:
		animation_player.play("attack_up_1")
	else:
		animation_player.play("attack_side_1")
	attack_cast = 0.6
	player.is_attacking = true
	player.can_flip = false
	await get_tree().create_timer(0.5).timeout 
	player.can_flip = true

func apply_damage(attack_direction: String):
	var areas = get_hited_enemys(attack_direction)
	var total_direction = Vector2(0, 0)
	var enemies_hit = []
	
	for area in areas:
		if area.is_in_group("player_enemies"):
			var enemy: Enemy = area.get_parent()
			var direction = calculate_knockback_direction(enemy)
			var new_damage_instance: DamageController.Damage_Instance = DamageController.create_damage_instance(player.sword_damage, player.sword_knockback_force, player.max_enemies_knockback)
			enemy.get_hited(new_damage_instance, direction, new_damage_instance.force_damage)
			enemy.pump()
			total_direction += direction
			enemies_hit.append(enemy)  
	
	var max_bounceness = get_max_bounceness(enemies_hit)
	
	if enemies_hit.size() > 0:
		player.pump()
		var average_direction = total_direction / enemies_hit.size()
		player.receive_knockback(-average_direction, 0.25, max_bounceness)

# Conta o cooldown de ataque
func update_attack_cast(delta: float):
	if player.is_attacking:
		attack_cast -= delta
		if attack_cast <= 0.0:
			player.is_attacking = false
			player.is_running = false
			animation_player.play("idle")

# Função que obtém os corpos sobrepostos
func get_hited_enemys(attack_direction: String) -> Array:
	if attack_direction == "up":
		return sword_area_up.get_overlapping_areas()
	elif attack_direction == "down":
		return sword_area_down.get_overlapping_areas()
	elif attack_direction == "side":
			if not player.sprite.flip_h:
				return sword_area_right.get_overlapping_areas()
			else:
				return sword_area_left.get_overlapping_areas()
	else:
		print("no attack")
		return sword_area_right.get_overlapping_areas()

func get_max_bounceness(enemies_hit: Array) -> float:
	var max_bounceness = 0.0
	for enemy in enemies_hit:
		if enemy.bounceness > max_bounceness:
			max_bounceness = enemy.bounceness
	return max_bounceness

func calculate_knockback_direction(enemy: Enemy) -> Vector2:
	return (enemy.global_position - player.global_position).normalized()
