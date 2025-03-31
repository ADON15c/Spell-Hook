extends Area2D

@export var spawnpoint: Node2D
var level: Level
var contained_players: Array[CharacterBody2D]

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
		body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	for player in contained_players:
		if player.is_on_floor():
			level.spawn_point = spawnpoint.position

func _on_body_entered(body):
	if body == level.player:
		contained_players.append(body)

func _on_body_exited(body):
	contained_players = contained_players.filter(func(p): return p != body)
