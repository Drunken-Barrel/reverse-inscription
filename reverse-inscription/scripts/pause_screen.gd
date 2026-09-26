extends CanvasLayer

# pre-load directories
@onready var ExitAreaButton: Button = $VBoxContainer/ExitAreaButton
@onready var ExitGameButton: Button = $VBoxContainer/ExitGameButton

# variables
var level_path: StringName = &"uid://c1djtk0ed5wy"
var level_select_path: StringName = &"uid://ct3fe338laoy5"
var main_menu_path: StringName = &"uid://ggbp2pq8cyo2"
var current_scene: StringName

func _ready() -> void:
	# connect signals
	ExitAreaButton.pressed.connect(_on_exit_area_pressed)
	ExitGameButton.pressed.connect(_on_exit_game_pressed)
	# get the uid of the current scene as a StringName
	current_scene = StringName(ResourceUID.id_to_text(ResourceLoader.get_resource_uid(get_tree().current_scene.scene_file_path)))
	# update the exit area button to match the current scene
	match current_scene:
		level_path:
			ExitAreaButton.text = "Exit Level"
		level_select_path:
			ExitAreaButton.text = "Exit Level Select"
		main_menu_path:
			ExitAreaButton.queue_free()

func _on_exit_area_pressed() -> void:
	# find which scene to switch to, load it and remove self from the scene tree
	match current_scene:
		level_path:
			SceneManager.load_scene(level_select_path)
			queue_free()
		level_select_path:
			SceneManager.load_scene(main_menu_path)
			queue_free()

func _on_exit_game_pressed() -> void:
	# quit the game
	get_tree().quit()
