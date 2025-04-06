@tool
extends Line2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var end_point: Vector2 = Vector2(0.0,0.0):
	set(val):
		end_point = val
		update_point()
@export_range(0.0,1.0) var length: float = 1.0:
	set(val):
		length = val
		update_point()

func _draw():
	var normalized_line_end: Vector2 = points[1]/width
	(material as ShaderMaterial).set_shader_parameter("end", normalized_line_end.length())

func update_point():
	points[1] = end_point*length

func set_visibility(new_visiblity: bool) -> void:
	if visible == new_visiblity:
		return
	elif new_visiblity == true:
		var tween: Tween = create_tween()
		length = 0.0
		tween.tween_property(self, "length", 1.0, 0.05)
		visible = true
	elif new_visiblity == false:
		var tween: Tween = create_tween()
		tween.tween_property(self, "length", 0.0, 0.05)
		tween.tween_callback(func(): visible = false)


func toggle_visiblity() -> void:
	set_visibility(!visible)
