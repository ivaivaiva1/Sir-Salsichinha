class_name Enemy
extends CharacterBody2D

@export var health: int = 10
@export var death_effect_prefab: PackedScene
@export var damage: float = 2
@export var damage_ui_prefab: PackedScene
@export var death_effect_scale: float
@export var meat_scene: PackedScene
var major_knockback_force: DamageController.Damage_Instance

var is_striking: bool = false
var actual_knockback: Vector2 = Vector2(0, 0)
var knockback_tween
@export var weight: float
var striked_enemies = []
var damages_receiveds = []
var last_damage_id : int
var body_knockback_force = 500
var actual_body_damage: float = 0

var suffered_damages_id: Array[int] = []

@onready var knockback_controller: Knockback_Controller = $"Knockback Controller"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_flash: AnimationPlayer = $HitFlash
@onready var sprite2d: Sprite2D = $Sprite2D
@onready var area2d: Area2D = $Area2D
@onready var strike_area2d: Area2D = $StrikeArea2D
@onready var damage_ui_pos: Marker2D = $DamageUIPos


var is_resting: bool = false
var rest_time: float = 0
var get_hited_cooldown: float = 0

func _process(delta):
	if rest_time > 0:
		rest_time -= delta
	else:
		animation_player.play("idle")
		is_resting = false
	
	if(get_hited_cooldown > 0):
		get_hited_cooldown -= delta
	
	if actual_knockback.x > 0 or actual_knockback.y:
		is_striking = true
	else:
		is_striking = false
	
	if not is_striking:
		if health <= 0:
			die()

func get_hited(damage_instance: DamageController.Damage_Instance, knockback_direction: Vector2):
	print(damage_instance)
	if damage_instance == null: return
	for ids in suffered_damages_id:
		if ids == damage_instance.force_id:
			print("id repetido")
			return
	suffered_damages_id.append(damage_instance.force_id)
	if damage_instance.force_power > 0:
		knockback_controller.call_knockback_controller(damage_instance, knockback_direction)
		strike_enemies_around()
		animation_player.play("idle")
	if damage_instance.force_damage > 0:
		take_damage(damage_instance.force_damage)

func take_damage(damage_amount: int):
	health -= damage_amount
	var damage_ui = damage_ui_prefab.instantiate()
	damage_ui.value = damage_amount
	damage_ui.global_position = damage_ui_pos.global_position
	get_parent().add_child(damage_ui)
	hit_flash.play("hit_flash")

func die():
	if is_striking: return
	if death_effect_prefab:
		var death_effect_object = death_effect_prefab.instantiate()
		death_effect_object.position = position
		death_effect_object.scale *= death_effect_scale
		death_effect_object.flip_h = true
		if(sprite2d.flip_h):
			#
			pass
		get_parent().add_child(death_effect_object)
	var index = randf_range(0, 100)
	if(index <= 2):
		var meat_object = meat_scene.instantiate()
		meat_object.position = position
		get_parent().add_child(meat_object)
	GameManager.kills += 1
	queue_free()

func do_rest():
	rest_time = 0.6
	is_resting = true

func do_strike(area: Area2D):
	var enemy: Enemy = area.get_parent()
	var direction = calculate_knockback_direction(enemy)
	await get_tree().create_timer(0.05).timeout
	if enemy != null:
		enemy.get_hited(major_knockback_force, direction)

func strike_enemies_around():
	var areas = strike_area2d.get_overlapping_areas()
	for area in areas:
		if area != null:
			if area.is_in_group("enemies"):
				do_strike(area)

func _on_area_2d_area_entered(area):
	if area == null: return
	if actual_knockback.x > 0 or actual_knockback.y > 0:
		if area.is_in_group("enemies"):
			do_strike(area)

	
	if is_striking: return
	if area == null: return
	if area.is_in_group("player"):
		do_rest()
		animation_player.play("attack")
		await get_tree().create_timer(0.4).timeout
		if GameManager.is_game_over: return
		if(animation_player.current_animation == "attack"):
				var player: Player = area.get_parent()
				player.take_damage(damage)

func pump():
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
