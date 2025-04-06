extends CanvasLayer

@onready var select = $Select

func _ready() -> void:
	select.button_clicked.connect(menu_select)
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if !get_tree().paused:
			get_tree().paused = true
			visible = true
		else:
			get_tree().paused = false
			visible = false


func menu_select(id: String):
	match id:
		"unpause":
			get_tree().paused = false
			visible = false
		"mainMenu":
			get_tree().paused = false
			SceneSwitcher.switch_scene(load("res://scenes/main_menu/main_menu.tscn"))
		"quitGame":
			get_tree().quit()
