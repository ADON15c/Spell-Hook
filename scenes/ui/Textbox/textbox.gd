@tool
extends NinePatchRect

@onready var label: Label = $Label

@export_multiline var text: String = "":
	set(value):
		text = value
		if is_node_ready():
			label.text = text

func _ready():
	label.text = text
