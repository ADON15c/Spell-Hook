extends Node2D

enum State {NORMAL, FOLLOW}

@export var stabilizer_id: String

var rotation_speed: float = 1.0
var origin: Vector2
var follow_body: Node2D
var state: State

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

func _ready() -> void:
	origin = position
	if stabilizer_id == null:
		print("stabilizer '%s' missing id" % name)
		return
	
	if stabilizer_id in SaveData.stabilizers_collected:
		sprite.modulate = Color(0.5,0.5,0.5,0.5)
	
	area.body_entered.connect(enter_follow)

func _process(delta: float) -> void:
	sprite.rotate(rotation_speed*delta)
	
	match state:
		State.NORMAL:
			position = origin
		State.FOLLOW:
			position = follow_body.position + Vector2(0.0,-60.0)

#func _on_area_2d_body_entered(body: Node2D):
	
	#if stabilizer_id not in SaveData.stabilizers_collected:
		#SaveData.stabilizers_collected.append(stabilizer_id)
		#SaveData.save_game()
	#queue_free()

func enter_follow(body: Node2D):
	body.death.connect(stop_follow, CONNECT_ONE_SHOT)
	body.landed.connect(collect, CONNECT_ONE_SHOT)
	state = State.FOLLOW
	follow_body = body
	area.set_deferred("monitoring", false)

func stop_follow():
	state = State.NORMAL
	follow_body = null
	area.set_deferred("monitoring", true)

func collect():
	if stabilizer_id not in SaveData.stabilizers_collected:
		SaveData.stabilizers_collected.append(stabilizer_id)
		SaveData.save_game()
	queue_free()
