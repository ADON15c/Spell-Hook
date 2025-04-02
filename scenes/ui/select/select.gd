extends NinePatchRect

@export var buttons: Dictionary[String, String]
@onready var button_container: VBoxContainer = $VBoxContainer
var button_nodes: Dictionary[String, Button]
var initial_button: Button

signal button_clicked(button_id: String)

func _ready():
	for key in buttons:
		var id: String = key
		var button: Button = Button.new()
		if initial_button == null:
			initial_button = button
		button.text = buttons[id]
		
		button.flat = true
		button.theme = load("res://scenes/ui/select/button_theme.tres")
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		button.button_down.connect(button_clicked.emit.bind(id))
		button_nodes.set(id, button)
		button_container.add_child(button)
	

func _input(event):
	if get_viewport().gui_get_focus_owner() != null:
		return
	
	for action in ["ui_up", "ui_down", "ui_left", "ui_right"]:
		if event.is_action_pressed(action):
			initial_button.grab_focus()
			get_viewport().set_input_as_handled()
