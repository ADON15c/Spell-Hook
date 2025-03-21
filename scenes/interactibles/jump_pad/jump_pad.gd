extends Node2D


const JUMP_PAD_STRENGTH: float = -1300.0

func _on_area_2d_body_entered(body: Node2D):
	if body.has_method("apply_velocity"):
		body.apply_velocity(Vector2(0,JUMP_PAD_STRENGTH).rotated(rotation))
	elif body is CharacterBody2D:
		body.velocity -= Vector2(0,JUMP_PAD_STRENGTH).rotated(rotation)
