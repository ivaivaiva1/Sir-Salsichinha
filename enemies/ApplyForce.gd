extends Node

@export var enemy: Enemy
@export var velocity_x: float
@export var velocity_y: float

func _ready():
	enemy = get_parent()

func _process(delta):
	enemy.velocity = Vector2(velocity_x, velocity_y)
	enemy.move_and_slide()
