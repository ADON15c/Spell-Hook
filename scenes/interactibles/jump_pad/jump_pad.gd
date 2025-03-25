@tool
extends Node2D

const JUMP_PAD_STRENGTH: float = 1300.0

enum Direction {UP, DOWN, RIGHT, LEFT}


@export var facing: Direction = Direction.UP:
	set(value):
		facing = value
		set_jump_pad_rotation(facing)


func _ready():
	set_jump_pad_rotation(facing)

func _on_area_2d_body_entered(body: Node2D):
	if body.has_method("set_velocity_x") && body.has_method("set_velocity_y"):
		match facing:
			Direction.UP:
				body.set_velocity_y(-JUMP_PAD_STRENGTH)
			Direction.DOWN:
				body.set_velocity_y(JUMP_PAD_STRENGTH)
			Direction.LEFT:
				body.set_velocity_x(-JUMP_PAD_STRENGTH)
			Direction.RIGHT:
				body.set_velocity_x(JUMP_PAD_STRENGTH)
	elif body is CharacterBody2D:
		body.velocity -= Vector2(0,JUMP_PAD_STRENGTH).rotated(rotation)

func set_jump_pad_rotation(dir: Direction):
	match dir:
		Direction.UP:
			rotation = 0
		Direction.DOWN:
			rotation = PI
		Direction.LEFT:
			rotation = PI*1.5
		Direction.RIGHT:
			rotation = PI*0.5
