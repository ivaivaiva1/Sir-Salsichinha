extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_spawn: AnimationPlayer = $AnimationPlayerSpawn

@export var speed: float
@export var xp_value: float

var blink_timer: float = 0
var blind_cooldown: float = 4

var move_direction: Vector2

var can_collect: bool = false
var state_escape: bool = false
var state_follow: bool = false

func _process(delta):
	if not can_collect: return
	set_move_direction()
	if blink_timer > 0:
		blink_timer -= delta
	if blink_timer <= 0:
		blink_timer = blind_cooldown
		animation_player.play("blink")
	
	if !state_escape and !state_follow:
		if is_near_player(100):
			start_gem_escape()
	
	if state_escape:
		speed -= delta * 8
		if speed <= 0:
			state_escape = false
			state_follow = true
	
	if state_follow:
		speed += delta * 16
		if is_near_player(20):
			gem_has_collected()

func _physics_process(delta):
	do_move()

func start_gem_escape():
	var difference = position - GameManager.player_position
	move_direction = difference.normalized()
	speed = 4
	state_escape = true

func set_move_direction():
	if !state_follow: return
	var player_position = GameManager.player_position
	var difference = player_position - position
	move_direction = difference.normalized()

func do_move():  
	velocity = move_direction * speed * 100
	move_and_slide()

func set_animation_idle():
	animation_player.play("idle")

func set_can_collect_true():
	can_collect = true

func spark_finished():
	animation_player.play("idle")
	animation_player_spawn.play("spawn")

func gem_has_collected():
	LevelingController.gain_experience(xp_value)
	queue_free()

func is_near_player(max_distance: float) -> bool:
	var player_position = GameManager.player_position
	var distance_to_player = position.distance_to(player_position)
	return distance_to_player <= max_distance
