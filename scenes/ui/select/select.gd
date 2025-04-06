extends NinePatchRect

@export var button_ordering: Dictionary[String, int]
@export var button_labels: Dictionary[String, String]
@export var clickable: Array[String]
@onready var button_container: VBoxContainer = $VBoxContainer
var initial_button: Button

signal button_clicked(button_id: String)

func _ready():
	var buttons: Array[Dictionary]
	for key in button_ordering:
		if key in button_labels:
			buttons.append({
				"id": key,
				"text": button_labels.get(key), 
				"order": button_ordering.get(key),
				"clickable": key in clickable
				})
		else:
			push_error("button missing label")
	
	buttons.sort_custom(func(a,b): return a["order"] < b["order"])
	
	for button in buttons:
		var control: Control
		if button["clickable"] == true:
			control = create_button(button["id"], button["text"])
			if initial_button == null:
				initial_button = control
		else:
			control = create_label(button["id"], button["text"])
		button_container.add_child(control)


func create_button(id, text) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.flat = true
	button.theme = load("res://resources/ui/ui_theme.tres")
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	button.button_down.connect(button_clicked.emit.bind(id))
	
	return button

func create_label(_id, text) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.theme = load("res://resources/ui/ui_theme.tres")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	return label

func _input(event):
	if get_viewport().gui_get_focus_owner() != null:
		return
	
	for action in ["ui_up", "ui_down", "ui_left", "ui_right"]:
		if event.is_action_pressed(action):
			initial_button.grab_focus()
			get_viewport().set_input_as_handled()
