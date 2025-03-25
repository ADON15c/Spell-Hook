extends Line2D

func _process(_delta):
	var normalized_line_end: Vector2 = points[1]/width
	(material as ShaderMaterial).set_shader_parameter("end", normalized_line_end.length())
