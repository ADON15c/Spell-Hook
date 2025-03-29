extends StaticBody2D

@onready var rotator: Node2D = $".."

func get_grapple_info():
	return rotator.get_grapple_info()
