class_name Enemy
extends CharacterBody2D

@export_category("Balancing Vars")
@export var speed: float = 1
@export var damage: float = 2
@export var health: int = 10
@export var weight: float
@export var bounceness: float
@export var rest_needed_time: float
@export var attack_range: float
@export var attack_cooldown: float

@export_category("Other vars")
@export var movement_type: String
@export var experience_gem: PackedScene
@export var death_effect_prefab: PackedScene
@export var damage_ui_prefab: PackedScene
@export var death_effect_scale: float
@export var meat_scene: PackedScene
var born_time: float
var major_knockback_force: DamageController.Damage_Instance
var distance_to_player: float
var attack_timer: float = 0
var actual_pump: int = 0
var is_flashing: bool = false

var is_striking: bool = false
var actual_knockback: Vector2 = Vector2(0, 0)
var actual_knockback_float: float
var actual_body_damage: float = 0
var suffered_damages_id: Array[int] = []

@onready var knockback_controller: Knockback_Controller = $"Knockback Controller"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pump_player: AnimationPlayer = $PumpAnimation
@onready var hit_flash: AnimationPlayer = $HitFlash
@onready var sprite2d: Sprite2D = $Sprite2D
@onready var area2d: Area2D = $Area2D
@onready var strike_area2d: Area2D = $StrikeArea2D
@onready var damage_ui_pos: Marker2D = $DamageUIPos
@onready var experience_pos: Marker2D = $ExperiencePos
@onready var dash_hit: Dash_Hit = $DashHit

var is_resting: bool = false
var rest_time: float = 0

func _ready():
	born_time = GameManager.time_elapsed

## Player's collision area
#func _on_area_2d_area_entered(area):
	#if actual_knockback != Vector2(0, 0): return
	#if area.is_in_group("player"):
		#do_rest()
		#animation_player.play("attack")

func _process(delta):
	check_actualKnockback_and_strike()
	distance_to_player = position.distance_to(GameManager.player_position)
	actual_knockback_float = actual_knockback.x + actual_knockback.y
	if rest_time > 0:
		rest_time -= delta
	else:
		animation_player.play("idle")
		is_resting = false
		pass
	
	if attack_timer > 0: attack_timer -= delta
	
	if distance_to_player < attack_range:
		if attack_timer > 0: return
		if actual_knockback != Vector2(0, 0): return
		if is_resting: return
		animation_player.play("attack")
		attack_timer = attack_cooldown
		do_rest()
	
	if health <= 0:
		die()

func check_actualKnockback_and_strike():
	if actual_knockback != Vector2(0, 0):
		var areas_around = strike_area2d.get_overlapping_areas()
		for area in areas_around:
			if area.is_in_group("enemies"):
				var enemy: Enemy = area.get_parent()
				do_strike(enemy)

func do_strike(striked_enemy: Enemy):
	var direction = calculate_knockback_direction(striked_enemy)
	var major_knockback = major_knockback_force
	await get_tree().create_timer(0.05).timeout
	if striked_enemy != null:
		#major_knockback.force_damage = adjust_damage(major_knockback.force_damage)
		var critical_hit: bool
		critical_hit = calculate_if_is_critical(major_knockback.is_critical, major_knockback.critical_chance)
		striked_enemy.get_hited(major_knockback, direction, critical_hit, "strike")

func calculate_if_is_critical(font_is_critical: bool, critical_chance: float) -> bool: 	
	var rand: float 
	rand = randf_range(0, 100)
	if font_is_critical:
		if rand <= critical_chance / 2:
			return true
		else:
			rand = randf_range(0, 100)
			if rand <= critical_chance / 4:
				return true
			else:
				return false
	else:
		if rand <= critical_chance / 2:
			return true
		else:
			return false

# Adjust the damage of the bounce based on the enemy's weight
func adjust_damage(base_force_power: float) -> float:
	var min_adjustment: float = 1 / 3.0  # Decrease by 3 times for weight 0
	var max_adjustment: float = 3.0  # Increase by 3 times for weight 10
	var max_weight: float = 10.0
	var adjustment: float = min_adjustment + (weight / max_weight) * (max_adjustment - min_adjustment)
	return base_force_power * adjustment

func get_hited(damage_instance: DamageController.Damage_Instance, knockback_direction: Vector2, is_critical: bool, hit_font: String):
	if dash_hit: dash_hit.is_following_player = false
	if hit_font != "player sword":
		if damage_instance.force_id in suffered_damages_id: return
		suffered_damages_id.append(damage_instance.force_id)
		if damage_instance.max_hited_enemies <= 0: 
			DamageController.destroy_damage_instance(damage_instance)
			return
		else:
			damage_instance.max_hited_enemies -= 1
	#if damage_instance == null: return
	if damage_instance.force_power > 0:
		is_striking = true
		knockback_controller.call_knockback_controller(damage_instance, knockback_direction)
		animation_player.play("idle")
	var damage: float = damage_instance.force_damage 
	if is_critical: damage *= damage_instance.critical_multiplier
	if damage > 0:
		take_damage(damage, is_critical, hit_font)

func take_damage(damage_amount: int, is_critical: bool, hit_font: String):
	if hit_font == "player sword" or hit_font == "strike":
		if(is_resting):
			animation_player.play("idle")
			is_resting = false
		if is_flashing == false:
			is_flashing = true
			hit_flash.play("hit_flash")
		if hit_font == "strike":
			pump(3)
		else:
			if is_critical:
				pump(1)
			else:
				pump(2)
	else:
		pump(5)
		modulate = Color.RED
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_QUINT)
		tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	var real_damage = randf_range((damage_amount / 1.05), (damage_amount * 1.05))
	health -= real_damage
	var damage_ui = damage_ui_prefab.instantiate()
	if is_critical: damage_ui.is_critical = true
	damage_ui.value = real_damage
	damage_ui.global_position = damage_ui_pos.global_position
	get_parent().add_child(damage_ui)


func strike_enemies_around():
	if actual_knockback_float == 0: return
	var areas = strike_area2d.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("enemies"):
			do_strike(area)
	pass

func hit_player():
	if GameManager.is_game_over: return
	GameManager.player.take_damage(damage)
	if GameManager.player.upgrade_sum_thorn == 0: return
	var rand: float = randf_range(0, 100)
	if rand <= (GameManager.player.base_critical_chance + GameManager.player.upgrade_sum_critical_chance):
		take_damage((GameManager.player.upgrade_sum_thorn * (GameManager.player.base_critical_multiplier + GameManager.player.upgrade_sum_critical_multiplier)), true, "thorn")
	else:
		take_damage(GameManager.player.upgrade_sum_thorn, false, "thorn")

func is_attack_finished():
	animation_player.play("resting")
	if GameManager.is_game_over: return


func update_is_striking():
	if actual_knockback == Vector2(0, 0):
		is_striking = false

func die():
	if is_striking: return
	instantiate_skul()
	instantiate_experience_gem()
	var index = randf_range(0, 100)
	if(index <= 2):
		var meat_object = meat_scene.instantiate()
		meat_object.global_position = experience_pos.global_position
		get_parent().add_child(meat_object)
	GameManager.kills += 1
	queue_free()

func instantiate_skul():
	return
	if death_effect_prefab:
		var death_effect_object = death_effect_prefab.instantiate()
		death_effect_object.position = position
		death_effect_object.scale *= death_effect_scale
		death_effect_object.flip_h = true
		if(sprite2d.flip_h):
			#
			pass
		get_parent().add_child(death_effect_object)

func instantiate_experience_gem():
	var gem = experience_gem.instantiate()
	gem.global_position = experience_pos.global_position
	get_parent().add_child(gem)

func do_rest():
	rest_time = rest_needed_time
	is_resting = true

func pump(pump_index: int):
	if actual_pump > pump_index: return
	if pump_index == 1:
		pump_player.play("pump_3")
		actual_pump = 1
	elif pump_index == 2:
		pump_player.play("pump_3")
		actual_pump = 2
	elif pump_index == 3:
		pump_player.play("pump_3")
		actual_pump = 3
	elif pump_index == 4:
		pump_player.play("pump_3")
		actual_pump = 4
	elif pump_index == 5:
		pump_player.play("pump_5")
		actual_pump = 5

func finish_pump():
	actual_pump = 0

func finish_flash():
	is_flashing = false


# Função que calcula a direção do knockback para um inimigo
func calculate_knockback_direction(enemy: Enemy) -> Vector2:
	var enemy_position = enemy.global_position
	var direction = (enemy_position - global_position).normalized()
	var player_position = GameManager.player_position
	var normalized_direction = direction.normalized()
	var new_position = enemy_position + normalized_direction
	if (new_position - player_position).length() < (enemy_position - player_position).length():
		direction *= -1
	return direction

	# --------------- Desequilíbrio --------------------
	#await get_tree().create_timer(0.35).timeout
	#var rotation_tween = get_tree().create_tween()
	#rotation_tween.set_ease(Tween.EASE_IN_OUT)
	#rotation_tween.set_trans(Tween.TRANS_QUINT)
	#rotation_tween.tween_property(self, "rotation_degrees", 20, 0.05)
	#rotation_tween.tween_property(self, "rotation_degrees", -20, 0.1)
	#rotation_tween.tween_property(self, "rotation_degrees", 13, 0.1)
	#rotation_tween.tween_property(self, "rotation_degrees", -13, 0.1)
	#rotation_tween.tween_property(self, "rotation_degrees", 6, 0.1)
	#rotation_tween.tween_property(self, "rotation_degrees", -6, 0.1)
	#rotation_tween.tween_property(self, "rotation_degrees", 0, 0.05)
