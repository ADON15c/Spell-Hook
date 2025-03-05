
extends Area2D
class_name Room
## A node describing a room in a level
##
## To be valid the Room must:
## - Contain a single CollisionShape2D
## - The CollisionShape2D must have a Rectangular Shape
## - The Rectangle must be larger than 1920x1080
## - The Spawnpoint property must be set to a marker, by convention that spawnpoint should be a child node


@export var spawnpoint: Marker2D
var bounds: Rect2

func _ready():
	var errors: Array[String] = check_valid()
	if not errors.is_empty():
		push_error(str(get_path()) + " Room is not valid: " + str(errors))
		return
	
	var collision_shape: CollisionShape2D = get_children().filter(func(child): return child is CollisionShape2D)[0]
	var rect_size: Vector2 = collision_shape.shape.size
	bounds = Rect2(collision_shape.global_position-(rect_size/2), rect_size)

func check_valid() -> Array[String]:
	var errors: Array[String] = []
	
	if spawnpoint == null:
		errors.append("Spawnpoint not set")
	
	var collision_shape_children: Array[Node] = get_children().filter(func(child): return child is CollisionShape2D)
	if collision_shape_children.size() > 1:
		errors.append("Too many collision shapes")
	elif collision_shape_children.size() < 1:
		errors.append("No collision shape")
	else:
		var collision_shape: CollisionShape2D = collision_shape_children[0]
		if collision_shape.shape is not RectangleShape2D:
			errors.append("Collision shape is not rectangle")
		var collision_shape_size: Vector2 = (collision_shape.shape as RectangleShape2D).size
		if  collision_shape_size.x < 1920 or collision_shape_size.y < 1080:
			errors.append("Room is smaller than camera")
	
	return errors
