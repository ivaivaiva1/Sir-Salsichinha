extends Node2D

@export var regeneration_amount: int = 10
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var blink_timer: float = 4
var blink_cooldown: float = 4

func _ready():
	$Area2D.body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		var player: Player = body
		player.heal(regeneration_amount)
		player.meat_collected.emit(regeneration_amount)
		queue_free()

func _process(delta):
	if blink_timer > 0:
		blink_timer -= delta
	if blink_timer <= 0:
		animation_player.play("blink")

func blink_finished():
	animation_player.play("idle")
	blink_timer = blink_cooldown
