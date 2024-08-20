class_name Enemy
extends CharacterBody2D

@export_category("Balancing Vars")
@export var speed: float = 1
@export var damage: float = 2
@export var health: int = 10
@export var weight: float
@export var bounceness: float
@export var rest_needed_time: float

@export_category("Other vars")
@export var movement_type: String
@export var experience_gem: PackedScene
@export var death_effect_prefab: PackedScene
@export var damage_ui_prefab: PackedScene
@export var death_effect_scale: float
@export var meat_scene: PackedScene
var born_time: float
var major_knockback_force: DamageController.Damage_Instance

var is_striking: bool = false
var actual_knockback: Vector2 = Vector2(0, 0)
var actual_knockback_float: float
var actual_body_damage: float = 0
var suffered_damages_id: Array[int] = []

@onready var knockback_controller: Knockback_Controller = $"Knockback Controller"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
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

func _process(delta):
	check_actualKnockback_and_strike()
	actual_knockback_float = actual_knockback.x + actual_knockback.y
	if rest_time > 0:
		rest_time -= delta
	else:
		animation_player.play("idle")
		is_resting = false
		pass
	
	if health <= 0:
		die()

func check_actualKnockback_and_strike():
	if actual_knockback != Vector2(0, 0):
		var areas_around = strike_area2d.get_overlapping_areas()
		for area in areas_around:
			if area.is_in_group("enemies"):
				do_strike(area)

func do_strike(striked_area: Area2D):
	var enemy: Enemy = striked_area.get_parent()
	var direction = calculate_knockback_direction(enemy)
	var major_knockback = major_knockback_force
	await get_tree().create_timer(0.05).timeout
	if enemy != null:
		enemy.get_hited(major_knockback, direction, adjust_damage(major_knockback.force_damage))

# Adjust the damage of the bounce based on the enemy's weight
func adjust_damage(base_force_power: float) -> float:
	var min_adjustment: float = 1 / 3.0  # Decrease by 3 times for weight 0
	var max_adjustment: float = 3.0  # Increase by 3 times for weight 10
	var max_weight: float = 10.0
	var adjustment: float = min_adjustment + (weight / max_weight) * (max_adjustment - min_adjustment)
	return base_force_power * adjustment

func get_hited(damage_instance: DamageController.Damage_Instance, knockback_direction: Vector2, real_damage: float):
	if dash_hit: dash_hit.is_following_player = false
	if damage_instance.force_id in suffered_damages_id: return
	suffered_damages_id.append(damage_instance.force_id)
	if not DamageController.check_max_hited_enemies(damage_instance): return
	if damage_instance == null: return
	if damage_instance.force_power > 0:
		GameManager.im_hited()
		is_striking = true
		knockback_controller.call_knockback_controller(damage_instance, knockback_direction)
		animation_player.play("idle")
	if real_damage > 0:
		take_damage(real_damage)

func take_damage(damage_amount: int):
	if(is_resting):
		animation_player.play("idle")
		is_resting = false
	var real_damage = randf_range((damage_amount / 1.30), (damage_amount * 1.30))
	health -= real_damage
	var damage_ui = damage_ui_prefab.instantiate()
	damage_ui.value = real_damage
	damage_ui.global_position = damage_ui_pos.global_position
	get_parent().add_child(damage_ui)
	hit_flash.play("hit_flash")

func strike_enemies_around():
	if actual_knockback_float == 0: return
	var areas = strike_area2d.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("enemies"):
			do_strike(area)
	pass

# Player's collision area
func _on_area_2d_area_entered(area):
	if actual_knockback != Vector2(0, 0): return
	if area.is_in_group("player"):
		do_rest()
		animation_player.play("attack")

func hit_player():
	if GameManager.is_game_over: return
	#var player: Player = area.get_parent()
	GameManager.player.take_damage(damage)


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
		meat_object.position = position
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

func pump():
	return
	# --------------- Amassada --------------------
	var scale_tween = get_tree().create_tween()
	scale_tween.set_ease(Tween.EASE_IN_OUT)
	scale_tween.set_trans(Tween.TRANS_QUINT)
	
	# Aumentar
	scale_tween.tween_property(self, "scale", Vector2(1.5, 0.3), 0.15)
	scale_tween.tween_property(self, "scale", Vector2(0.6, 1.2), 0.35)
	
	#Diminuir
	scale_tween.set_ease(Tween.EASE_IN)
	scale_tween.set_trans(Tween.TRANS_QUINT)
	scale_tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
	
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
	
	# --------------- Pulinho --------------------
	await get_tree().create_timer(0.33).timeout
	var jump_tween = get_tree().create_tween()
	
	# Pulo para cima (aumenta a posição Y para simular um pulo)
	jump_tween.set_ease(Tween.EASE_OUT)
	jump_tween.set_trans(Tween.TRANS_QUINT)
	jump_tween.tween_property(sprite2d, "position:y", -50, 0.1)
	
	# Voltar ao chão (restaura a posição Y)
	jump_tween.set_ease(Tween.EASE_IN)
	jump_tween.set_trans(Tween.TRANS_QUAD)
	jump_tween.tween_property(sprite2d, "position:y", 0, 0.1)

# Função que calcula a direção do knockback para um inimigo
func calculate_knockback_direction(enemy: Enemy) -> Vector2:
	return (enemy.global_position - global_position).normalized()



