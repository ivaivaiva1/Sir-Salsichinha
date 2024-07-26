class_name Player
extends CharacterBody2D

@export var speed: float = 2.5
@export var sword_damage: int = 0
@export var sword_knockback_force: float = 800
@export var health: int = 100
@export var max_health: int = 100
@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene
@export var death_effect_prefab: PackedScene
@export var ritual_knockback_force: float = 500

var knockback: Vector2 = Vector2(0, 0)
var knockback_tween
var auto_knock_back_force: float = 200
var keep_input_x: float = 0
var can_flip: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_box: Area2D = $Area2D
@onready var sword_area_left: Area2D = $SwordAreaLeft
@onready var sword_area_right: Area2D = $SwordAreaRight
@onready var sprite2d: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar

var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cast: float = 0
var take_damage_cooldown: float = 0
var frame_freeze_cooldown: float = 0
@export var frame_freeze_time: float = 0.1
signal meat_collected(value:int)


func _ready():
	# Ritual
	#do_ritual()
	GameManager.player = self
	pass

func _process(delta):
	call_manager()
	# Input
	read_input()
	
	# Ataque
	update_attack_cast(delta)
	if Input.is_action_just_pressed("attack"):
		attack()
	
	# Animações
	rotate_sprite()
	play_run_idle_animation()
	
	# Receber dano
	#update_hit_box(delta)
	health_bar.max_value = max_health
	health_bar.value = health
	if frame_freeze_cooldown > 0:
		frame_freeze_cooldown -= delta

func _physics_process(delta):
	do_move()

# Faz o ritual automaticamente
func do_ritual():
	await get_tree().create_timer(ritual_interval).timeout 
	var ritual = ritual_scene.instantiate()
	ritual.knockback_force = ritual_knockback_force
	ritual.damage_amount = ritual_damage
	add_child(ritual)
	do_ritual()

# Conta o cooldown de ataque
func  update_attack_cast(delta: float):
	if is_attacking:
		attack_cast -= delta
		if attack_cast <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

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
	var movement_direction = lerp(velocity, target_velocity, 0.35)
	velocity = movement_direction + knockback
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

# Inicia o ataque
func attack():
	if is_attacking:
		return
	
	#var choseAttack = randi_range(0, 1)
	#if choseAttack == 0:
	#	animation_player.play("attack_side_1")
	#elif choseAttack == 1:
	#	animation_player.play("attack_side_2")
	can_flip = false
	animation_player.play("attack_side_1")
	attack_cast = 0.6
	is_attacking = true
	can_flip = false
	await get_tree().create_timer(0.5).timeout 
	can_flip = true

# Aplica o dano do ataque ao inimigo
func apply_damage(stop_time: float = 0.15):
	var bodies = get_overlapping_bodies()
	var total_direction = Vector2(0, 0)
	var enemies_hit = 0
	
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction = calculate_knockback_direction(enemy)
			var damage_id = randi_range(0, 1000000)
			enemy.get_hited(sword_damage, direction, sword_knockback_force, damage_id)
			enemy.pump()
			total_direction += direction
			enemies_hit += 1
	
	if enemies_hit > 0:
		pump()
		var average_direction = total_direction / enemies_hit
		apply_knockback(-average_direction, stop_time)

# Função que obtém os corpos sobrepostos
func get_overlapping_bodies() -> Array:
	if not sprite.flip_h:
		return sword_area_left.get_overlapping_bodies()
	else:
		return sword_area_right.get_overlapping_bodies()

# Função que calcula a direção do knockback para um inimigo
func calculate_knockback_direction(enemy: Enemy) -> Vector2:
	return (enemy.global_position - global_position).normalized()

# Função que aplica o knockback ao player
func apply_knockback(knockback_direction: Vector2, stop_time: float):
	knockback = knockback_direction * auto_knock_back_force
	if knockback_tween:
		knockback_tween.kill()
	var knockback_tween = get_tree().create_tween()
	knockback_tween.set_ease(Tween.EASE_IN)
	knockback_tween.set_trans(Tween.TRANS_QUINT)
	knockback_tween.tween_property(self, "knockback", Vector2(0, 0), stop_time)


func call_manager():
	GameManager.player_position = position

func take_damage(amount: int):
	if health <= 0: return
	
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
	Engine.time_scale = 0.3
	await get_tree().create_timer(frame_freeze_time * 0.3).timeout 
	Engine.time_scale = 1
	frame_freeze_cooldown = frame_freeze_time

func die():
	if death_effect_prefab:
		var death_effect_object = death_effect_prefab.instantiate()
		death_effect_object.position = position
		get_parent().add_child(death_effect_object)
	GameManager.end_game()
	GameManager.is_game_over = true
	queue_free()

func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	return health

func pump():
	# --------------- Amassada --------------------
	var scale_tween = get_tree().create_tween()
	scale_tween.set_ease(Tween.EASE_IN_OUT)
	scale_tween.set_trans(Tween.TRANS_QUINT)
	
	# Aumentar
	scale_tween.tween_property(sprite2d, "scale", Vector2(1.3, 0.7), 0.1)
	scale_tween.tween_property(sprite2d, "scale", Vector2(0.7, 1.3), 0.15)
	
	#Diminuir
	scale_tween.set_ease(Tween.EASE_IN)
	scale_tween.set_trans(Tween.TRANS_QUINT)
	scale_tween.tween_property(sprite2d, "scale", Vector2(1, 1), 0.1)
