extends Node

var stabilizers_collected: Array[String] = [] ## List of obtained stabilizer ids 

func _ready() -> void:
	load_game()

func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var data = {"stabilizers_collected": stabilizers_collected}
	var json_data = JSON.stringify(data)
	save_file.store_line(json_data)

func load_game():
	if FileAccess.file_exists("user://savegame.save"):
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var json_data = JSON.new()
		json_data.parse(save_file.get_as_text())
		stabilizers_collected.assign(json_data.data["stabilizers_collected"])
