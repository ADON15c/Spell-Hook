extends Control

@onready var cutscene_texture: TextureRect = $MarginContainer/TextureRect
@onready var cutscene_label: Label = $MarginContainer2/Label


@export var cutscene: Cutscene = load("res://resources/cutscenes/test_cutscene.tres")
var next_segment_idx: int = 0
var scene_transition_timer: SceneTreeTimer

func _ready():
	load_next_segment()

func load_next_segment():
	if next_segment_idx >= cutscene.segments.size():
		match cutscene.scene_type:
			cutscene.SceneType.NORMAL:
				SceneSwitcher.switch_scene(cutscene.next_scene)
			cutscene.SceneType.LEVEL:
				SceneSwitcher.load_level(cutscene.next_scene)
		return
		
	var segment: CutsceneSegment = cutscene.segments[next_segment_idx]
	next_segment_idx += 1
	cutscene_texture.texture = segment.image
	cutscene_label.text = segment.text
	if sign(segment.duration) != -1:
		scene_transition_timer = get_tree().create_timer(segment.duration)
		scene_transition_timer.timeout.connect(load_next_segment)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if scene_transition_timer:
			scene_transition_timer.timeout.disconnect(load_next_segment)
			scene_transition_timer = null
		load_next_segment()
