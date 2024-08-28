extends Node2D

@onready var labelTxt: Label = %Label
@onready var scaleController: Node2D = %ScaleController

@export var normalColor: Color
@export var criticalColor: Color

var value: int = 0

var is_critical: bool = false

func _ready():
	labelTxt.text = str(value)
	if is_critical:
		#scaleController.scale = Vector2(1.2, 1.2)
		labelTxt.modulate = criticalColor
	else:
		scaleController.scale = Vector2(0.7, 0.7)
		labelTxt.modulate = normalColor
