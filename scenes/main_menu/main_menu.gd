extends Node2D

var cutscene1: Cutscene = preload("res://resources/cutscenes/level_1_start/level_1_start.tres")
var cutscene2: Cutscene = preload("res://resources/cutscenes/level_2_start/level_2_start.tres")

func _ready():
	$Select.button_clicked.connect(menu_select)
	
func menu_select(id: String):
	match id:
		"level1":
			SceneSwitcher.load_cutscene(cutscene1)
		"level2":
			SceneSwitcher.load_cutscene(cutscene2)
		"quit":
			get_tree().quit()
