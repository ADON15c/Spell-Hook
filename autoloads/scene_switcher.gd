extends Node

var level_container: PackedScene = preload("res://scenes/level_container/level_container.tscn")
var current_scene: Node = null

# Folliwng code from end of https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html accessed April 5th 2025

func _ready():
	var root = get_tree().root
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	current_scene = root.get_child(-1)

func switch_scene(scene: PackedScene):
	_deferred_switch_scene.call_deferred(scene)

func _deferred_switch_scene(scene: PackedScene):
	current_scene.free()
	current_scene = scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

func load_level(level: PackedScene):
	_deferred_load_level.call_deferred(level)

func _deferred_load_level(level: PackedScene):
	current_scene.free()
	current_scene = level_container.instantiate()
	current_scene.current_level_scene = level
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
