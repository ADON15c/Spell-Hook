extends Resource
class_name CutsceneSegment

## Texture displayed for segment
@export var image: Texture2D
## Duration of segment
## Set to a negative value to make it unlimited
@export var duration: float
## Text displayed for segment
@export_multiline var text: String
