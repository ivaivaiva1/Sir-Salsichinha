class_name Player
extends CharacterBody2D

@export_category("Balancing Vars")
@export var base_speed: float = 2.5
@export var base_sword_damage: int = 10
@export var base_critical_chance: float = 40
@export var base_critical_multiplier: float = 3
@export var base_block_chance: int = 0
@export var base_sword_knockback_force: float = 500
@export var base_max_health: int = 300
@export var base_max_enemies_knockback: int = 100
@export var base_magnetic: float = 150
@export var base_luck: int = 10
@export var base_auto_knock_back_force: float = 300

@export_category("Level UP Multipliers")
var upgrade_multiplier_attack_speed: float = 1
var upgrade_multiplier_attack_range: float = 1
var upgrade_sum_sword_damage: int = 0
var upgrade_sum_movement_speed: float = 0
var upgrade_sum_knockback_force: int = 0
var upgrade_sum_max_enemies_knockback: int = 0
var upgrade_sum_critical_chance: int = 0
var upgrade_sum_critical_multiplier: float = 0
var upgrade_sum_block_chance: int = 30
var upgrade_sum_max_health: int = 0
var upgrade_sum_max_armor: float = 0
var upgrade_sum_life_regen: float = 9
var upgrade_sum_luck: int = 0
var upgrade_sum_magnetic: int = 0
var upgrade_sum_thorn: int = 45

@export_category("Other vars")
var knockback: Vector2 = Vector2(0, 0)
var knockback_tween	
var keep_input_x: float = 0
var can_flip: bool = true
var health: float = 0

@export_category("Prefabs")
@export var block_ui_prefab: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = %MainPlayer
@onready var range_player: AnimationPlayer = %RangePlayer
@onready var hit_box: Area2D = %Area2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_bar_trans: ProgressBar = $HealthBarTrans
@onready var block_ui_pos: Marker2D = $BlockUIPos
@onready var do_attack_gd: Node = %DoAttack


var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var take_damage_cooldown: float = 0
var frame_freeze_cooldown: float = 0
var frame_freeze_time: float = 0.1
signal meat_collected(value:int)

func _ready():
	# Ritual
	#do_ritual()
	Engine.time_scale = 1
	GameManager.kills = 0
	GameManager.time_elapsed = 0
	GameManager.is_game_over = false
	LevelingController.level = 1
	LevelingController.experience = 0
	LevelingController.total_experience = 0
	range_player.play("1.5")
	health = base_max_health
	health_bar.max_value = base_max_health
	health_bar_trans.max_value = base_max_health
	health_bar.value = health
	health_bar_trans.value = health
	GameManager.player = self
	pass

func _process(delta):
	health_bar.value = health
	health_bar_trans.value = health
	call_manager()
	call_life_regen(delta)
	
	if Input.is_action_just_pressed("pause"):
		if Engine.time_scale != 0:
			Engine.time_scale = 0
		else:
			Engine.time_scale = 1
	
	
	
	# Input
	read_input()
	
	# Animações
	rotate_sprite()
	play_run_idle_animation()
	
	# Update frame freeze cooldown
	if frame_freeze_cooldown > 0:
		frame_freeze_cooldown -= delta

func call_life_regen(delta):
	if health >= base_max_health + upgrade_sum_max_health: return
	if upgrade_sum_life_regen == 0: return
	health += delta * (upgrade_sum_life_regen)


func _physics_process(delta):
	do_move()

# Obtem o input vector
func read_input():
	var player_input = Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.15)
	
	#Apagar deadzone do input vector
	if abs(input_vector.x) < 0.3:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.3:
		input_vector.y = 0.0
	input_vector = player_input
	
	# Atualiza o is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

func normalize_input_vector(InputVector: Vector2) -> Vector2:
	var ControlDirection: Vector2 = Vector2(1, 0)
	var DesiredDirection: Vector2 = Vector2(0, 1)
	
	return DesiredDirection.rotated(deg_to_rad(45) * floor(ControlDirection.angle_to(InputVector) / deg_to_rad(45)))

# Move o Player
func do_move():
	var target_velocity = input_vector * (base_speed + upgrade_sum_movement_speed) * 100
	if is_attacking:
		target_velocity *= 0.5
	if(knockback != Vector2(0, 0)):
		velocity = knockback
	else:
		var movement_direction = lerp(velocity, target_velocity, 0.35)
		velocity = movement_direction
	move_and_slide()

# Toca as animações run e idle
func play_run_idle_animation():
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

# Girar sprite
func rotate_sprite():
	if(input_vector.x != 0):
		keep_input_x = input_vector.x
	if can_flip:
		if keep_input_x > 0:
			sprite.flip_h = false
		elif keep_input_x < 0:
			sprite.flip_h = true

# Função que aplica o knockback ao player
func receive_knockback(knockback_direction: Vector2, stop_time: float, enemy_bounceness: float):
	knockback = knockback_direction * adjust_auto_knockback(enemy_bounceness)
	if knockback_tween:
		knockback_tween.kill()
	var knockback_tween = get_tree().create_tween()
	knockback_tween.set_ease(Tween.EASE_IN)
	knockback_tween.set_trans(Tween.TRANS_QUINT)
	knockback_tween.tween_property(self, "knockback", Vector2(0, 0), stop_time)

# Função que mapeia o bounceness para a força do knockback
func adjust_auto_knockback(bounceness: float) -> float:
	var min_bounceness = 0.0
	var max_bounceness = 10.0
	var min_knockback = base_auto_knock_back_force / 1.3
	var max_knockback = base_auto_knock_back_force * 1.3
	
	# Regra de três para mapear o bounceness para a força do knockback
	var knockback_force = min_knockback + (bounceness - min_bounceness) / (max_bounceness - min_bounceness) * (max_knockback - min_knockback)
	return knockback_force

func call_manager():
	GameManager.player_position = position

func take_damage(amount: int, enemy: Enemy):
	if health <= 0: return
	var rand: int = randi_range(0, 100)
	if rand <= (base_block_chance + upgrade_sum_block_chance):
		var block_ui = block_ui_prefab.instantiate()
		block_ui.global_position = block_ui_pos.global_position
		get_parent().add_child(block_ui)
		do_block_hit(enemy)
		return
	do_thorn_hit(enemy)
	var realDamage: float
	realDamage = amount * (1 - (upgrade_sum_max_armor / 100))
	if realDamage <= 0: return
	health -= realDamage
	
	frameFreeze()
	#Piscar player
	pump()
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Processar morte
	if health <= 0:
		die()

func frameFreeze():
	if frame_freeze_cooldown > 0: return
	Engine.time_scale = 0.1
	await get_tree().create_timer(frame_freeze_time * 0.1).timeout 
	Engine.time_scale = 1
	frame_freeze_cooldown = frame_freeze_time

func die():
	get_tree().reload_current_scene()
	GameManager.end_game()
	GameManager.is_game_over = true
	queue_free()

func heal(amount: int):
	health += amount
	if health > base_max_health:
		health = base_max_health
	health_bar.value = health
	health_bar_trans.value = health

func do_thorn_hit(enemy: Enemy):
	if GameManager.player.upgrade_sum_thorn == 0: return
	var rand: float = randf_range(0, 100)
	if rand <= (GameManager.player.base_critical_chance + GameManager.player.upgrade_sum_critical_chance):
		enemy.take_damage((upgrade_sum_thorn * (base_critical_multiplier + upgrade_sum_critical_multiplier)), true, "thorn")
	else:
		enemy.take_damage(upgrade_sum_thorn, false, "thorn")

func do_block_hit(enemy: Enemy):
	var direction = calculate_knockback_direction(enemy)
	var is_critical: bool = false
	var rand = randf_range(0, 100)
	if rand <= base_critical_chance + upgrade_sum_critical_chance: is_critical = true
	var new_damage_instance: DamageController.Damage_Instance = DamageController.create_damage_instance((base_sword_damage + upgrade_sum_sword_damage + upgrade_sum_thorn), (base_sword_knockback_force + upgrade_sum_knockback_force), (base_max_enemies_knockback + upgrade_sum_max_enemies_knockback), is_critical, (base_critical_chance + upgrade_sum_critical_chance), (base_critical_multiplier + upgrade_sum_critical_multiplier))
	enemy.get_hited(new_damage_instance, direction, is_critical, "player block")

func calculate_knockback_direction(enemy: Enemy) -> Vector2:
	return (enemy.global_position - global_position).normalized()

func pump():
	# --------------- Amassada --------------------
	var scale_tween = get_tree().create_tween()
	scale_tween.set_ease(Tween.EASE_IN_OUT)
	scale_tween.set_trans(Tween.TRANS_QUINT)
	
	# Aumentar
	scale_tween.tween_property(sprite, "scale", Vector2(1.3, 0.7), 0.1)
	scale_tween.tween_property(sprite, "scale", Vector2(0.7, 1.3), 0.15)
	
	#Diminuir
	scale_tween.set_ease(Tween.EASE_IN)
	scale_tween.set_trans(Tween.TRANS_QUINT)
	scale_tween.tween_property(sprite, "scale", Vector2(1, 1), 0.1)
