extends Node2D

enum RotationDir {Clockwise = 1, CounterClocokwise = -1}

@export var rotation_amount: float = 0.0
@export var rotation_direction: RotationDir = RotationDir.Clockwise
var rotation_speed: float = 1.0/1.0 # Inverse of time for full rotation
var grapple_type: Player.State = Player.State.GRAPPLE_ROTATOR

@onready var SpriteLimit: Sprite2D = $SpriteLimit
@onready var SpriteCenter: Sprite2D = $SpriteCenter


func _ready():
	SpriteLimit.rotation = rotation_amount*rotation_direction
	SpriteCenter.flip_v = rotation_direction == RotationDir.CounterClocokwise

func get_grapple_info():
	return {
		"state": Player.State.GRAPPLE_ROTATOR, 
		"grapple_effect_info": {
			"node": self,
			"rotation_amount": rotation_amount,
			"rotation_speed": rotation_speed*rotation_direction
			
			}
		}

func rotate_center(amount: float):
	SpriteCenter.rotate(amount)

func reset_center_rotation():
	SpriteCenter.rotation = 0
