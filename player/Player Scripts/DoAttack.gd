extends Node

var player: Player

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sword_area_left: Area2D = %SwordAreaLeft
@onready var sword_area_right: Area2D = %SwordAreaRight
@onready var sword_area_up: Area2D = %SwordAreaUp
@onready var sword_area_down: Area2D = %SwordAreaDown

var time_to_last_attack: float = 0
var is_pending_attack: bool = false
var last_attack_type: String
var attack_index: int
var can_pending_normal_attack: bool = false

func _ready():
	player = get_parent()

func _process(delta):
	print(attack_index)
	time_to_last_attack += delta
	if Input.is_action_just_pressed("attack"):
		if player.is_attacking:
			if attack_index == 1 or can_pending_normal_attack:
				is_pending_attack =  true
		else:
			attack()
	if is_pending_attack:
		if !player.is_attacking:
			attack()
	if time_to_last_attack > 0.8 and attack_index == 1: 
		attack_index = 0

# Inicia o ataque
func attack():
	if player.is_attacking: return
	if attack_index == 2: attack_index = 0
	var rand: int = randi_range(0, 100)
	if attack_index == 1 or rand <= player.critical_chance:
		if player.input_vector.y > 0:
			animation_player.play("attack_down_2")
		elif player.input_vector.y < 0:
			animation_player.play("attack_up_2")
		else:
			animation_player.play("attack_side_2")
		last_attack_type = "Critical"
	else: 
		if player.input_vector.y > 0:
			animation_player.play("attack_down_1")
		elif player.input_vector.y < 0:
			animation_player.play("attack_up_1")
		else:
			animation_player.play("attack_side_1")
		last_attack_type = "Normal"
	can_pending_normal_attack = false
	player.can_flip = false
	attack_index += 1
	is_pending_attack = false
	time_to_last_attack = 0
	player.is_attacking = true
	player.can_flip = false

func apply_damage(attack_direction: String, is_critical: bool = false):
	var areas = get_hited_enemys(attack_direction)
	var total_direction = Vector2(0, 0)
	var enemies_hit = []
	
	for area in areas:
		if area.is_in_group("player_enemies"):
			var enemy: Enemy = area.get_parent()
			var direction = calculate_knockback_direction(enemy)
			var new_damage_instance: DamageController.Damage_Instance = DamageController.create_damage_instance(player.sword_damage, player.sword_knockback_force, player.max_enemies_knockback, is_critical, player.critical_chance, player.critical_multiplier)
			enemy.get_hited(new_damage_instance, direction, is_critical)
			enemy.pump()
			total_direction += direction
			enemies_hit.append(enemy)  
	
	var max_bounceness = get_max_bounceness(enemies_hit)
	
	if enemies_hit.size() > 0:
		player.pump()
		var average_direction = total_direction / enemies_hit.size()
		player.receive_knockback(-average_direction, 0.25, max_bounceness)

func set_can_flip_true():
	player.can_flip = true
	can_pending_normal_attack = true

# Conta o cooldown de ataque
func attack_is_finished():
	#if player.is_attacking:
		#attack_cast -= delta
		#if attack_cast <= 0.0:
			#player.is_attacking = false
			#player.is_running = false
			#animation_player.play("idle")
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
		return sword_area_right.get_overlapping_areas()

func get_max_bounceness(enemies_hit: Array) -> float:
	var max_bounceness = 0.0
	for enemy in enemies_hit:
		if enemy.bounceness > max_bounceness:
			max_bounceness = enemy.bounceness
	return max_bounceness

func calculate_knockback_direction(enemy: Enemy) -> Vector2:
	return (enemy.global_position - player.global_position).normalized()
