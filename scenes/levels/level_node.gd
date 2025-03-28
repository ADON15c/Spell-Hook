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
signal spawned_player(player: Node)

var has_player: bool
var player: Node2D
var has_rooms: bool
var rooms: Array[Room]
var current_room: Room
var new_room: Room
var spawn_point: Vector2


func _ready():
	if rooms_node and rooms_node.get_children().all(func(node): return (node is Room) and (node as Room).check_valid().is_empty()) and starting_room:
		has_rooms = true
		
		rooms.assign(rooms_node.get_children())
		current_room = starting_room
		spawn_point = current_room.spawnpoint.position
		
		for room in rooms:
			var room_body_entered = func(body: Node2D):
				if body == player:
					new_room = room
			var room_body_exited = func(body: Node2D):
				if body == player and new_room != null and room == current_room:
					spawn_point = new_room.spawnpoint.position
					current_room.deactivate()
					new_room.activate()
					changed_room.emit(new_room.bounds)
					
					current_room = new_room
					new_room = null
					
			room.body_entered.connect(room_body_entered)
			room.body_exited.connect(room_body_exited)

	if player_scene and player_scene.can_instantiate():
		has_player = true
		spawn_player()

func spawn_player():
	if !has_player:
		return

	player = player_scene.instantiate()
	call_deferred("add_child", player)
	if player.has_signal("death"):
		player.death.connect(restart)
	player.position = spawn_point
	var room: Room = get_room_at_point(player.position)
	if room:
		current_room = room
		changed_room.emit(room.bounds)

	spawned_player.emit(player)

func get_room_at_point(point: Vector2) -> Room:
	var space_state = get_world_2d().direct_space_state
	var physicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	physicsPointQueryParameters2D.position = point
	physicsPointQueryParameters2D.collide_with_areas = true
	physicsPointQueryParameters2D.collision_mask = 8
	var results = space_state.intersect_point(physicsPointQueryParameters2D)
	if results.size() != 1:
		return null
	else :
		return results[0].collider

func restart():
	if has_player:
		spawn_player()
