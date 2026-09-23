extends Node

# pre-load all directories
@onready var LevelSelectButton: Button = $LevelSelectButton

# variables
var level_select: StringName = &"uid://ct3fe338laoy5"

func _ready() -> void:
	LevelSelectButton.pressed.connect(_on_level_select_button_pressed)

func _on_level_select_button_pressed():
	SceneManager.load_scene(level_select)
