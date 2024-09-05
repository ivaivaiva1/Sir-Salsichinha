extends Node2D

@onready var labelTxt: Label = %Label
@onready var scaleController: Node2D = $ScaleController
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var normalColor: Color
@export var criticalColor: Color

var value: int = 0

var is_critical: bool = false

func _ready():
	labelTxt.text = str("-" , value)
	if is_critical:
		scaleController.scale = Vector2(0.9, 0.9)
		labelTxt.modulate = criticalColor
		animation_player.speed_scale = 1.4
	else:
		scaleController.scale = Vector2(0.7, 0.7)
		labelTxt.modulate = normalColor
		animation_player.speed_scale = 1.7

#Damage Falling parameters
#func _ready():
	#labelTxt.text = str("-" , value)
	#if is_critical:
		#scaleController.scale = Vector2(0.9, 0.9)
		#labelTxt.modulate = criticalColor
		#animation_player.speed_scale = 1
	#else:
		#scaleController.scale = Vector2(0.7, 0.7)
		#labelTxt.modulate = normalColor
		#animation_player.speed_scale = 1

#Damage Default parameters
#func _ready():
	#labelTxt.text = str("-" , value)
	#if is_critical:
		#scaleController.scale = Vector2(0.9, 0.9)
		#labelTxt.modulate = criticalColor
		#animation_player.speed_scale = 1.4
	#else:
		#scaleController.scale = Vector2(0.7, 0.7)
		#labelTxt.modulate = normalColor
		#animation_player.speed_scale = 1.7
