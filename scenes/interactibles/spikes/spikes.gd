@tool
extends Node2D

const JUMP_PAD_STRENGTH: float = 1300.0

enum Direction {UP, DOWN, RIGHT, LEFT}


@export var facing: Direction = Direction.UP:
	set(value):
		facing = value
		set_spike_rotation(facing)


func _ready():
	set_spike_rotation(facing)

func _on_area_2d_body_entered(body: Node2D):
	if body.has_method("kill") && body.has_method("set_velocity_y"):
		body.kill()

func set_spike_rotation(dir: Direction):
	match dir:
		Direction.UP:
			rotation = 0
		Direction.DOWN:
			rotation = PI
		Direction.LEFT:
			rotation = PI*1.5
		Direction.RIGHT:
			rotation = PI*0.5
