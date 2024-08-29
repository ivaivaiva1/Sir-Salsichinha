class_name Player
extends CharacterBody2D

@export_category("Balancing Vars")
@export var speed: float = 2.5
@export var sword_damage: int = 0
@export var critical_chance: float = 5
@export var critical_multiplier: float = 1.5
@export var sword_knockback_force: float = 700
@export var max_health: int = 100
@export var max_enemies_knockback: int = 30
@export var auto_knock_back_force: float = 300
#max 900 min 500?

@export_category("Other vars")
var knockback: Vector2 = Vector2(0, 0)
var knockback_tween	
var keep_input_x: float = 0
var can_flip: bool = true
var health: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = %MainPlayer
@onready var hit_box: Area2D = %Area2D
@onready var health_bar: ProgressBar = $HealthBar

var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var take_damage_cooldown: float = 0
var frame_freeze_cooldown: float = 0
@export var frame_freeze_time: float = 0.1
signal meat_collected(value:int)

func _ready():
	# Ritual
	#do_ritual()
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	GameManager.player = self
	pass

func _process(delta):
	call_manager()
	
	# Input
	read_input()
	
	# Animações
	rotate_sprite()
	play_run_idle_animation()
	
	# Update frame freeze cooldown
	if frame_freeze_cooldown > 0:
		frame_freeze_cooldown -= delta

func _physics_process(delta):
	do_move()

# Obtem o input vector
func read_input():
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.15)
	
	# Apagar deadzone do input vector
	#var deadzone = 0.15
	#if abs(input_vector.x) < 0.15:
		#input_vector.x = 0.0
	#if abs(input_vector.y) < 0.15:
		#input_vector.x = 0.0
	
	# Atualiza o is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

# Move o Player
func do_move():
	var target_velocity = input_vector * speed * 100
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
	var min_knockback = auto_knock_back_force / 1.3
	var max_knockback = auto_knock_back_force * 1.3
	
	# Regra de três para mapear o bounceness para a força do knockback
	var knockback_force = min_knockback + (bounceness - min_bounceness) / (max_bounceness - min_bounceness) * (max_knockback - min_knockback)
	return knockback_force

func call_manager():
	GameManager.player_position = position

func take_damage(amount: int):
	if health <= 0: return
	
	health_bar.value = health
	
	health -= amount
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
	GameManager.end_game()
	GameManager.is_game_over = true
	queue_free()

func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	health_bar.value = health
	return health

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
