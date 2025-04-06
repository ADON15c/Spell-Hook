extends Node2D

var cutscene1: Cutscene = preload("res://resources/cutscenes/test_cutscene.tres")
var level2: PackedScene = preload("res://scenes/levels/test_level/test_level.tscn")

func _ready():
	$Select.button_clicked.connect(menu_select)
	
func menu_select(id: String):
	match id:
		"level1":
			SceneSwitcher.load_cutscene(cutscene1)
		"level2":
			SceneSwitcher.load_level(level2)
		"quit":
			get_tree().quit()
