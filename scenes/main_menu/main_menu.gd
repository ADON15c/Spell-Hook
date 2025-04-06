extends Node2D

var level1: PackedScene = preload("res://scenes/levels/level_1/level_1.tscn")
var level2: PackedScene = preload("res://scenes/levels/test_level/test_level.tscn")

func _ready():
	$Select.button_clicked.connect(menu_select)
	
func menu_select(id: String):
	match id:
		"level1":
			SceneSwitcher.load_level(level1)
		"level2":
			SceneSwitcher.load_level(level2)
		"quit":
			get_tree().quit()
