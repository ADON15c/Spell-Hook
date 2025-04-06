extends Resource
class_name Cutscene

enum SceneType {NORMAL, LEVEL}

@export var segments: Array[CutsceneSegment]
@export var next_scene: PackedScene
@export var scene_type: SceneType
