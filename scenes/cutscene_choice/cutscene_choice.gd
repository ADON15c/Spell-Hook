extends Control

@onready var bad_button: Button = $HBoxContainer/Control/PrayButton
@onready var pray_button: Button = $HBoxContainer/Control2/StopButton
@onready var stable_button: Button = $HBoxContainer/Control3/StableButton

var bad_cutscene: Cutscene = load("res://resources/cutscenes/game_end/game_end_bad.tres")
var neutral_cutscene: Cutscene = load("res://resources/cutscenes/game_end/game_end_neutral.tres")
var pray_cutscene: Cutscene = load("res://resources/cutscenes/game_end/game_end_good.tres")
var stable_cutscene: Cutscene = load("res://resources/cutscenes/game_end/game_end_true.tres")

func _ready():
	var collected_stabilizers = SaveData.stabilizers_collected.size()
	stable_button.text = stable_button.text % collected_stabilizers
	if collected_stabilizers < 6:
		stable_button.disabled = true
	
	bad_button.button_down.connect(roll_the_dice)
	pray_button.button_down.connect(func(): SceneSwitcher.load_cutscene(pray_cutscene))
	stable_button.button_down.connect(func(): SceneSwitcher.load_cutscene(stable_cutscene))
	
	pray_button.grab_focus()

func roll_the_dice():
	if randf() > 0.3:
		SceneSwitcher.load_cutscene(bad_cutscene)
	else:
		SceneSwitcher.load_cutscene(neutral_cutscene)
