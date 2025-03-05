extends Node2D

@export var current_level_scene: PackedScene

var current_level: Level
var level_supports_rooms: bool = false

@onready var camera: Camera2D = $Camera2D


func _ready():
	if !current_level_scene:
		return
	
	current_level = current_level_scene.instantiate()
	add_child(current_level)
	
	if current_level.has_player:
		var remote_transform: RemoteTransform2D = RemoteTransform2D.new()
		remote_transform.remote_path = camera.get_path()
		current_level.player.add_child(remote_transform)
	
	if current_level.has_rooms:
		current_level.changed_room.connect(set_camera_bounds)

func set_camera_bounds(bounds: Rect2):
	camera.limit_left = round(bounds.position.x)
	camera.limit_right = round(bounds.size.x + bounds.position.x)
	camera.limit_top = round(bounds.position.y)
	camera.limit_bottom = round(bounds.size.y + bounds.position.y)
