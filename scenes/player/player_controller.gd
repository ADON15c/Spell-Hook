extends CharacterBody2D

enum State {NORMAL, GRAPPLE}


# ----------------------------------------
# ------ MEMBER VARIABLES/CONSTANTS ------
# ----------------------------------------

var player_state: State = State.NORMAL

var RUN_ACCEL: float = 2700.0     # Run acceleration speed. Also acts as decceleration speed when changing direction
var RUN_REDUCE: float = 1350.0    # Speed reduction from going over RUN_MAX
var RUN_MAX: float = 325.0        # Max speed from running

var GRAVITY: float = 2000.0       # How fast falling speed increases
var MAX_FALL: float = 1000.0      # Max falling speed
var JUMP_VELOCITY: float = -700.0 # Velocity Applied on Jump

var GRAPPLE_RANGE: float = 500.0  # Grapple Hook Range
var GRAPPLE_BOOST: float = 2.5    # velocity multiplier from starting grapple

const DEBUG_DRAW: bool = false

var facing_left: bool = false
var grapple_pos: Vector2
var grapple_angle: float = 0
var grapple_angle_fixed: bool = false

func _process(delta):
	if not grapple_angle_fixed:
		var input_dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
		grapple_angle = input_dir.angle()

# -------------------------------
# ------ PHYSICS PROCESSES ------
# -------------------------------

func _physics_process(delta):
	match player_state:
		State.NORMAL:
			_physics_process_normal(delta)
		State.GRAPPLE:
			_physics_process_grapple(delta)  


func _physics_process_normal(delta):
	if Input.is_action_just_pressed("grapple"):
		create_grapple()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, MAX_FALL, GRAVITY * delta)
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
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
	
	move_and_slide()
	queue_redraw()


func _physics_process_grapple(delta):
	if Input.is_action_just_pressed("grapple"):
		player_state = State.NORMAL
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, MAX_FALL, GRAVITY * delta)
	
	project_velocity()
	move_and_slide()
	queue_redraw()


# ---------------------------
# ------ GRAPPLE STUFF ------
# ---------------------------

func create_grapple():
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(to_global(Vector2(0, 0)), to_global(Vector2(GRAPPLE_RANGE, 0).rotated(grapple_angle)))
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		return
	
	grapple_pos = result.position
	player_state = State.GRAPPLE

	project_velocity()
	velocity *= GRAPPLE_BOOST


func project_velocity():
	var offset_pos = position - grapple_pos
	var tangent = offset_pos.rotated(PI/2)
	# Vector Projection Formula
	var velocity_projected = (velocity.dot(tangent)/pow(tangent.length(), 2))*tangent

	velocity = velocity_projected


# -------------------
# ------ OTHER ------
# -------------------

func face(left: bool):
	facing_left = left
	$Sprite2D.flip_h = left


func _draw():
	if player_state == State.GRAPPLE:
		draw_line(Vector2(0,0), to_local(grapple_pos), Color.BLACK, 2)
	else:
		draw_line(Vector2(0,0), Vector2(GRAPPLE_RANGE, 0).rotated(grapple_angle), Color.GRAY, 2)
	
	if DEBUG_DRAW:
		draw_line(Vector2(0, 0), Vector2(velocity.x/5, 0), Color.GREEN, 2)
		draw_line(Vector2(0, 0), Vector2(0, velocity.y/5), Color.RED, 2)
		draw_line(Vector2(0, 0), velocity/5, Color.BLUE, 2)
		
		if player_state == State.GRAPPLE:
			var offset_pos: Vector2 = position - grapple_pos
			var tangent = Vector2(offset_pos.x + 1, offset_pos.y-(offset_pos.x/offset_pos.y)) - offset_pos

			draw_line(Vector2(0,0), tangent.normalized()*25, Color.BLUE, 2)
