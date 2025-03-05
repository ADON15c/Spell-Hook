extends Node2D
class_name Level
## A node describing a level
##
## Most levels should be split into rooms (even if there is only one room) and have a player set
## To add rooms
## - Add a child node called "Rooms"
## - Add the valid Room nodes as children to that
## - Set the starting rooms property

@export var player_scene: PackedScene
@export var rooms_node: Node # Node containing rooms
@export var starting_room: Room # Starting rooms
signal changed_room(room_bounds: Rect2)

var has_player: bool
var player: Node2D
var has_rooms: bool
var rooms: Array[Room]
var current_room: Room


func _ready():
	if player_scene and player_scene.can_instantiate():
		has_player = true
		player = player_scene.instantiate()
		add_child(player)
	

	if rooms_node and rooms_node.get_children().all(func(node): return (node is Room) and (node as Room).check_valid().is_empty()) and starting_room:
		has_rooms = true
		
		rooms.assign(rooms_node.get_children())
		current_room = starting_room
		player.position = current_room.spawnpoint.position
		
		for room in rooms:
			var room_body_entered = func(body: Node2D):
				if body == player:
					current_room = room
					changed_room.emit(room.bounds)
			room.body_entered.connect(room_body_entered)
