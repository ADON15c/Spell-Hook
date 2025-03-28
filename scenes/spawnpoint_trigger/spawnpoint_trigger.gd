extends Area2D

@export var spawnpoint: Node2D
var level: Level

func _ready():
	var parent: Node = get_parent()
	while parent:
		if parent is Level:
			level = parent
			break
		else:
			parent = parent.get_parent()
	
	if level:	
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body == level.player:
		level.spawn_point = spawnpoint.position
