class_name Enemy
extends CharacterBody2D

@export var health: int = 10
@export var death_effect_prefab: PackedScene
@export var damage: float = 2
@export var damage_ui_prefab: PackedScene
@export var death_effect_scale: float
@export var meat_scene: PackedScene

var is_striking: bool = false
var knockback: Vector2 = Vector2(0, 0)
var knockback_tween
@export var weight: float
var striked_enemies = []
var damages_receiveds = []
var last_damage_id : int
var body_knockback_force = 500

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_flash: AnimationPlayer = $HitFlash
@onready var sprite2d: Sprite2D = $Sprite2D
@onready var area2d: Area2D = $Area2D
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
		get_hited_cooldown -= 0.1
	
	
	if not is_striking:
		if health <= 0:
			die()

func get_hited(damage_amount: int, knockback_direction: Vector2, knockback_force: float, damage_id: int, striker: Enemy = null):
	# Verifica se o inimigo ja tomou dano dessa mesma fonte
	#var check_font: bool = !damages_receiveds.has(damage_id)
	#print(check_font) 
	#if !check_font: return
	#damages_receiveds.append(damage_id)
	#last_damage_id = damage_id
	
	if(get_hited_cooldown > 0): return
	get_hited_cooldown = 0.5
	
	apply_knockback(knockback_direction, knockback_force, damage_id, striker)
	if damage_amount == 0: return
	take_damage(damage_amount)

func take_damage(damage_amount: int):
	health -= damage_amount
	var damage_ui = damage_ui_prefab.instantiate()
	damage_ui.value = damage_amount
	damage_ui.global_position = damage_ui_pos.global_position
	get_parent().add_child(damage_ui)
	hit_flash.play("hit_flash")


func apply_knockback(knockback_direction: Vector2, knockback_force: float, damage_id: int, striker: Enemy = null):
	# Knockback code
	striked_enemies.clear()
	if(striker):
		striked_enemies.append(striker)
	if(knockback_force > 0):
		
		is_striking = true
		animation_player.play("idle")
		check_and_strike_enemies(damage_id)
		fix_knockback_direction(knockback_direction)
		knockback = knockback_direction * knockback_force
		var knockback_tween = get_tree().create_tween()
		knockback_tween.set_ease(Tween.EASE_IN)
		knockback_tween.set_trans(Tween.TRANS_QUINT)
		knockback_tween.tween_property(self, "knockback", Vector2(0, 0), 0.35)
		#knockback_tween.tween_callback(Callable(self, "on_knockback_finish"))
		await get_tree().create_timer(0.3).timeout
		is_striking = false
		striked_enemies.clear()


func fix_knockback_direction(direction: Vector2) -> Vector2:
	var player_position = GameManager.player_position
	var enemy_position = global_position
	var normalized_direction = direction.normalized()
	# Calcula a nova posição após o knockback
	var new_position = enemy_position + normalized_direction
	# Verifica se o knockback empurra o inimigo na direção do player
	if (new_position - player_position).length() < (enemy_position - player_position).length():
		# Inverte a direção do knockback para evitar empurrar o inimigo na direção do player
		direction *= -1
	return direction

func die():
	if death_effect_prefab:
		var death_effect_object = death_effect_prefab.instantiate()
		death_effect_object.position = position
		death_effect_object.scale *= death_effect_scale
		if(sprite2d.flip_h):
			death_effect_object.flip_h = true
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

func _on_area_2d_area_entered(area):
	if is_striking:
		if area.is_in_group("enemies"):
			var enemy: Enemy = area.get_parent()
			#if enemy not in striked_enemies:
			striked_enemies.append(enemy)
			var direction = calculate_knockback_direction(enemy)
			enemy.get_hited(2, direction, body_knockback_force, last_damage_id)
			if(get_hited_cooldown <= 0):
				enemy.pump()
	
	if is_striking: return
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

func check_and_strike_enemies(damage_id: int):
	var areas = area2d.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("enemies"):
			var enemy: Enemy = area.get_parent()
			#if enemy not in striked_enemies:
			striked_enemies.append(enemy)
			var direction = calculate_knockback_direction(enemy)
			enemy.get_hited(2, direction, body_knockback_force, damage_id, self)
			if get_hited_cooldown < 0:
				enemy.pump()

# Função que calcula a direção do knockback para um inimigo
func calculate_knockback_direction(enemy: Enemy) -> Vector2:
	return (enemy.global_position - global_position).normalized()
