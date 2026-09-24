extends Node

# pre-load all directories
@onready var Level1Button: Button = $Level1Button

# variables
var level_path: StringName = &"uid://c1djtk0ed5wy"

func _ready() -> void:
	Level1Button.pressed.connect(_on_level1_button_pressed)

func _on_level1_button_pressed():
	SceneManager.load_scene(level_path,1)
