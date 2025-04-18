extends CharacterBody2D
class_name Player

enum State {NORMAL, GRAPPLE, GRAPPLE_ROTATOR}
signal death
signal landed

#region PLAYER SETTINGS

var RUN_ACCEL: float = 2700.0     # Run acceleration speed. Also acts as decceleration speed when changing direction
var RUN_REDUCE: float = 1350.0    # Speed reduction from going over RUN_MAX
var RUN_MAX: float = 325.0        # Max speed from running

var GRAVITY: float = 2000.0       # How fast falling speed increases
var MAX_FALL: float = 1000.0      # Max falling speed
var JUMP_VELOCITY: float = -900.0 # Velocity Applied on Jump

var GRAPPLE_RANGE: float = 300.0  # Grapple Hook Range
var GRAPPLE_BOOST: float = 1.0    # velocity multiplier from starting grapple

const DEBUG_DRAW: bool = false

#endregion

#region MEMBER VARIABLES

@onready var grapple_line: Line2D = $GrappleLine

var player_state: State = State.NORMAL

var jumping: bool = false

var grapple_pos: Vector2
var grapple_angle: float = -PI/2
var grapple_angle_fixed: bool = false
var grapple_dist: float
var angular_velocity: float
var grapple_effect_info: Dictionary 

var grapple_rotator_distance: float

var grounded: bool = true
var facing_left: bool = false
var dead: bool = false

#endregion

#region NODE VIRTUALS

func _input(event):
	if event.is_action_pressed("restart"):
		kill()

func _process(_delta):
	if not grapple_angle_fixed:
		grapple_angle = get_input_dir().angle()

func _physics_process(delta):
	match player_state:
		State.NORMAL:
			_physics_process_normal(delta)
		State.GRAPPLE:
			_physics_process_grapple(delta)
		State.GRAPPLE_ROTATOR:
			_physics_process_grapple_rotator(delta)
	
	if is_grappling():
		grapple_line.end_point = to_local(grapple_pos)

func _draw():
	if !is_grappling() and get_input_dir() != Vector2(0.0,0.0):
		draw_line(Vector2(0,0), Vector2(GRAPPLE_RANGE, 0).rotated(grapple_angle), Color.GRAY, 2)
		#var result = grapple_raycast()
		#if result.is_empty():
			#return
		#else:
			#draw_circle(to_local(result.position),10.0,Color.RED)
			#draw_line(Vector2(0,0), to_local(result.position), Color.RED, 2)
			#
			#draw_circle(to_local(result.position), to_local(result.position).length(), Color.GREEN, false, 2)
	#else:
		#draw_circle(to_local(grapple_pos), to_local(grapple_pos).length(), Color.GREEN, false, 2)
			
	if DEBUG_DRAW:
		draw_line(Vector2(0, 0), Vector2(velocity.x/5, 0), Color.GREEN, 2)
		draw_line(Vector2(0, 0), Vector2(0, velocity.y/5), Color.RED, 2)
		draw_line(Vector2(0, 0), velocity/5, Color.BLUE, 2)
		
		if is_grappling():
			var offset_pos: Vector2 = position - grapple_pos
			var tangent = Vector2(offset_pos.x + 1, offset_pos.y-(offset_pos.x/offset_pos.y)) - offset_pos

			draw_line(Vector2(0,0), tangent.normalized()*100, Color.BLUE, 2)

#endregion

#region STATE NORMAL

func _physics_process_normal(delta):
	if Input.is_action_just_pressed("grapple"):
		create_grapple()
	
	# Add the gravity.
	if grounded == false and is_on_floor() == true:
		landed.emit()
	grounded = is_on_floor()
	if not grounded:
		velocity.y = move_toward(velocity.y, MAX_FALL, GRAVITY * delta)
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and grounded:
		velocity.y = JUMP_VELOCITY
		jumping = true
	if jumping and not Input.is_action_pressed("jump"):
		velocity.y = max(velocity.y,JUMP_VELOCITY/4.0)
		jumping = false
	if jumping and velocity.y >= 0:
		jumping = false
	
	# Horizontal Movement
	var direction = Input.get_axis("move_left", "move_right")
	direction = 1 if (direction > 0) else -1 if (direction < 0) else 0
	
	if (facing_left and direction>0):
		face(false)
	elif (not facing_left and direction<0):
		face(true)
		
	if abs(velocity.x) > RUN_MAX && sign(velocity.x) == direction:
		velocity.x = move_toward(velocity.x, RUN_MAX * direction, RUN_REDUCE * delta)
	else:
		velocity.x = move_toward(velocity.x, RUN_MAX * direction, RUN_ACCEL * delta)
	
	if grounded:
		($Sprite2D.texture as AtlasTexture).region.position = Vector2(0,0)
	elif velocity.y < 0:
		($Sprite2D.texture as AtlasTexture).region.position = Vector2(0,75)
	else:
		($Sprite2D.texture as AtlasTexture).region.position = Vector2(0,150)
	
	move_and_slide()
	queue_redraw()

#endregion

#region GRAPPLE HELPERS

func grapple_move(delta: float) -> bool:
	var polar_pos: Vector2 = cartesian_to_polar(position)
	polar_pos = Vector2(grapple_dist, polar_pos.y + (angular_velocity/polar_pos.x)*delta)
	var new_position: Vector2 = polar_to_cartesian(polar_pos)
	var test_collision: KinematicCollision2D = KinematicCollision2D.new()
	var collided: bool = test_move(transform, new_position-position, test_collision)
	var previously_grounded: bool = grounded
	
	if collided: # Handle collision
		angular_velocity = 0
		var normal: Vector2 = test_collision.get_normal()
		position += test_collision.get_travel()
		# The above collision correction will slightly move us closer or further from the grapple point, this corercts that
		if normal.x != 0:
			# This formula comes from solving the intersection between a circle representing the grapple point and a line representing our players y-axis
			# Since this a quadratic we have two solutions. Which one we chose depends which side of the circle we are on
			var side_sign: int = 1 if polar_pos.y >=0 else -1
			# Use shifted verion of player position with grapple at 0,0 to make math easier
			var shifted_position: Vector2 = position-grapple_pos
			shifted_position.y = side_sign*sqrt(grapple_dist*grapple_dist - shifted_position.x*shifted_position.x)
			position = shifted_position + grapple_pos
		elif normal.y != 0:
			# Same process as above but for shifting on x-axis
			var side_sign: int = 1 if abs(polar_pos.y) <= PI/2 else -1
			var shifted_position: Vector2 = position-grapple_pos
			shifted_position.x = side_sign*sqrt(grapple_dist*grapple_dist - shifted_position.y*shifted_position.y)
			position = shifted_position + grapple_pos
		if normal.y == -1.0:
			grounded = true
	else:
		if new_position.y < position.y:
			grounded = false
		position = new_position
	
	if previously_grounded == false and grounded == true:
		landed.emit()
	
	return !collided

func grapple_raycast() -> Dictionary:
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(to_global(Vector2(0, 0)), to_global(Vector2(GRAPPLE_RANGE, 0).rotated(grapple_angle)))
	query.collision_mask = 16 # grapple_surface
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		return {}
	
	var grapple_info = {}
	var collider: Node2D = result.collider
	if collider is TileMapLayer:
		var tilemap: TileMapLayer = collider as TileMapLayer
		grapple_info["position"] = tilemap.map_to_local(tilemap.get_coords_for_body_rid(result.rid))
	else:
		grapple_info["position"] = collider.global_position
	
	if collider.has_method("get_grapple_info"):
		var collider_grapple_info = collider.get_grapple_info()
		grapple_info["state"] = collider_grapple_info["state"]
		grapple_effect_info = collider_grapple_info["grapple_effect_info"]
	else:
		grapple_info["state"] = Player.State.GRAPPLE
	
	return grapple_info

func create_grapple():
	var result = grapple_raycast()
	if result.is_empty():
		return
	else:
		grapple_pos = result.position
	
	grapple_line.set_visibility(true)
	grapple_line.end_point = to_local(grapple_pos)
	grapple_dist = grapple_pos.distance_to(position)
	player_state = result.state
	
	# TODO: If I implement a proper state machine, add this code to the start function for each state
	match player_state:
		State.GRAPPLE:
			velocity_to_angular_velocity()
			angular_velocity *= GRAPPLE_BOOST
		State.GRAPPLE_ROTATOR:
			grapple_rotator_distance = grapple_effect_info["rotation_amount"]
			angular_velocity=grapple_dist*grapple_effect_info["rotation_speed"]*2*PI # grapple_effect_info["rotation_amount"]
	
	jumping = false

func velocity_to_angular_velocity():
	var offset_pos = position - grapple_pos # Position relative to grapple
	var tangent = offset_pos.rotated(PI/2)
	var velocity_projected = velocity.project(tangent)
	var angular_velocity_magnitude = velocity_projected.length()
	
	var offset_grapple = grapple_pos-position # Grapple position relative to player
	var angular_velocity_direction = 1 if offset_grapple.angle_to(velocity_projected) < 0 else -1
	angular_velocity = angular_velocity_direction*angular_velocity_magnitude

func angular_velocity_to_velocity():
	var offset_pos = position - grapple_pos # Position relative to grapple
	var tangent = offset_pos.rotated(PI/2).normalized()
	velocity = tangent * angular_velocity


func cartesian_to_polar(cartesian: Vector2) -> Vector2:
	var ang: float = grapple_pos.angle_to_point(cartesian)
	var dist: float = grapple_pos.distance_to(cartesian)
	return Vector2(dist, ang)

func polar_to_cartesian(polar: Vector2) -> Vector2:
	return Vector2.RIGHT.rotated(polar.y)*polar.x + grapple_pos

#endregion

#region STATE GRAPPLE

func _physics_process_grapple(delta):
	($Sprite2D.texture as AtlasTexture).region.position = Vector2(0,225)
	
	# Add the gravity.
	if not grounded:
		angular_velocity_to_velocity()
		velocity.y = move_toward(velocity.y, MAX_FALL, GRAVITY * delta)
		velocity_to_angular_velocity()
		
	grapple_move(delta)

	if Input.is_action_just_released("grapple"):
		angular_velocity_to_velocity()
		player_state = State.NORMAL
		grapple_line.set_visibility(false)

#endregion

#region STATE GRAPPLE_ROTATOR

func _physics_process_grapple_rotator(delta):
	($Sprite2D.texture as AtlasTexture).region.position = Vector2(0,225)
	
	#angular_velocity = 1000.0
	var collision = !grapple_move(delta)
	var rotation_distance: float = angular_velocity*delta/grapple_dist
	grapple_rotator_distance -= abs(rotation_distance)
	grapple_effect_info["node"].rotate_center(rotation_distance)
	
	if collision || grapple_rotator_distance < 0:
		angular_velocity_to_velocity()
		player_state = State.NORMAL
		grapple_line.set_visibility(false)
		grapple_effect_info["node"].reset_center_rotation()

#endregion

#region OTHER

func face(left: bool):
	facing_left = left
	$Sprite2D.flip_h = left

func apply_velocity(distance: Vector2):
	match player_state:
		State.NORMAL:
			velocity += distance
		State.GRAPPLE:
			angular_velocity_to_velocity()
			velocity += distance
			velocity_to_angular_velocity()

func set_velocity_x(new_x: float):
	match player_state:
		State.NORMAL:
			velocity.x = new_x
		State.GRAPPLE:
			angular_velocity_to_velocity()
			velocity.x = new_x
			velocity_to_angular_velocity()

func set_velocity_y(new_y: float):
	match player_state:
		State.NORMAL:
			velocity.y = new_y
		State.GRAPPLE:
			angular_velocity_to_velocity()
			velocity.y = new_y
			velocity_to_angular_velocity()

func kill():
	if not dead:
		dead = true
		death.emit()
		queue_free()

func is_grappling():
	return player_state in [State.GRAPPLE, State.GRAPPLE_ROTATOR]

func get_input_dir():
	var input_dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	input_dir.x = sign(input_dir.x)
	input_dir.y = sign(input_dir.y)
	return input_dir

#endregion
