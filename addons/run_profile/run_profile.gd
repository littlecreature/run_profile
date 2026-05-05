@tool
extends Resource
class_name RunProfile

enum WindowMode {
	TOP_LEFT,
	CENTERED,
	CUSTOM_POSITION,
	FORCE_MAXIMISED,
	FORCE_FULLSCREEN
}

@export var id: String
@export var display_name: String
@export var icon: Texture2D
@export var selected: bool = false

@export_enum(
	"Top Left",
	"Centered",
	"Custom Position",
	"Force Maximised",
    "Force Fullscreen"
)
var mode: int = WindowMode.CENTERED

@export var custom_x: int = 0
@export var custom_y: int = 0
