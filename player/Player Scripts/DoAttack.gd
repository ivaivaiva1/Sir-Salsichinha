extends Node

var player: Player

@onready var animation_player: AnimationPlayer = %MainPlayer
@onready var animation_crit: AnimationPlayer = %CriticalEffectPlayer
@onready var sword_area_left: Area2D = %SwordAreaLeft
@onready var sword_area_right: Area2D = %SwordAreaRight
@onready var sword_area_up: Area2D = %SwordAreaUp
@onready var sword_area_down: Area2D = %SwordAreaDown
@onready var critical_effect_sprite: Sprite2D = %CriticalEffect

var time_to_last_attack: float = 0
var is_pending_attack: bool = false
var last_attack_type: String
var attack_index: int
var can_pending_normal_attack: bool = false

func _ready():
	player = get_parent().get_parent()

func _process(delta):
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
	if attack_index == 1 or rand <= (player.base_critical_chance + player.upgrade_sum_critical_chance):
		if player.input_vector.y > 0.5:
			animation_player.play("attack_down_2", -1, player.upgrade_multiplier_attack_speed)
			set_critical_effect_position("down")
		elif player.input_vector.y < -0.5:
			animation_player.play("attack_up_2", -1, player.upgrade_multiplier_attack_speed)
			set_critical_effect_position("up")
		else:
			animation_player.play("attack_side_2", -1, player.upgrade_multiplier_attack_speed)
			set_critical_effect_position("side")
		last_attack_type = "Critical"
		animation_crit.play("critical_effect")
	else: 
		if player.input_vector.y > 0.5:
			animation_player.play("attack_down_1", -1, player.upgrade_multiplier_attack_speed)
		elif player.input_vector.y < -0.5:
			animation_player.play("attack_up_1", -1, player.upgrade_multiplier_attack_speed)
		else:
			animation_player.play("attack_side_1", -1, player.upgrade_multiplier_attack_speed)
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
	var new_damage_instance: DamageController.Damage_Instance = DamageController.create_damage_instance((player.base_sword_damage + player.upgrade_sum_sword_damage), (player.base_sword_knockback_force + player.upgrade_sum_knockback_force), (player.base_max_enemies_knockback + player.upgrade_sum_max_enemies_knockback), is_critical, (player.base_critical_chance + player.upgrade_sum_critical_chance), (player.base_critical_multiplier + player.upgrade_sum_critical_multiplier))
	for area in areas:
		if area.is_in_group("player_enemies"):
			var enemy: Enemy = area.get_parent()
			var direction = calculate_knockback_direction(enemy)
			enemy.get_hited(new_damage_instance, direction, is_critical, "player sword")
			total_direction += direction
			enemies_hit.append(enemy)  
	
	var max_bounceness = get_max_bounceness(enemies_hit)
	
	if enemies_hit.size() > 0:
		player.pump()
		var average_direction = total_direction / enemies_hit.size()
		player.receive_knockback(-average_direction, 0.25, max_bounceness)

func set_critical_effect_position(attack_direction: String):
	if attack_direction == "up": critical_effect_sprite.position = Vector2(-6, -100)
	if attack_direction == "down": critical_effect_sprite.position = Vector2(9, 14)
	if attack_direction == "side":
		if player.sprite.flip_h:
			critical_effect_sprite.position = Vector2(-51, -6)
		else:
			critical_effect_sprite.position = Vector2(51, -6)

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
