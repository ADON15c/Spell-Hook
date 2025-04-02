extends Node2D

func _ready():
	$Select.button_clicked.connect(menu_select)
	
func menu_select(id: String):
	match id:
		"level1":
			get_tree().change_scene_to_file("res://scenes/game/game.tscn")
		"quit":
			get_tree().quit()
