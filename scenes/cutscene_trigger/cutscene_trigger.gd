extends Area2D

enum Cutscenes {Level1, Level2, End}

@export var cutscene: Cutscenes # Should take a Cutscene resource directly, wasn't working for some strange reason I couldn't figure out

func _ready():
	if !cutscene:
		print("%s missing cutscene" % name)
	
	body_entered.connect(start_switch)

func _process(_delta: float) -> void:
	pass

func start_switch(_body):
	var cutscene_resource: Cutscene
	match cutscene:
		Cutscenes.Level1:
			cutscene_resource = load("res://resources/cutscenes/level_1_start/level_1_start.tres")
		Cutscenes.Level2:
			cutscene_resource = load("res://resources/cutscenes/level_2_start/level_2_start.tres")
		Cutscenes.End:
			cutscene_resource = load("res://resources/cutscenes/game_end/game_end.tres")
	SceneSwitcher.load_cutscene(cutscene_resource)
