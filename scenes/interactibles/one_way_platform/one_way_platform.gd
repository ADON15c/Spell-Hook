@tool
extends Node2D

const JUMP_PAD_STRENGTH: float = 1300.0

enum Direction {UP, DOWN, RIGHT, LEFT}


@export var facing: Direction = Direction.UP:
	set(value):
		facing = value
		set_platform_rotation(facing)


func _ready():
	set_platform_rotation(facing)


func set_platform_rotation(dir: Direction):
	match dir:
		Direction.UP:
			rotation = 0
		Direction.DOWN:
			rotation = PI
		Direction.LEFT:
			rotation = PI*1.5
		Direction.RIGHT:
			rotation = PI*0.5
