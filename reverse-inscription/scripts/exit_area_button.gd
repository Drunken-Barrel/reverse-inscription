extends Button

# variables
var level_path: StringName = &"uid://c1djtk0ed5wy"
var level_select_path: StringName = &"uid://ct3fe338laoy5"
var main_menu_path: StringName = &"uid://ggbp2pq8cyo2"
var current_scene: StringName

func _ready() -> void:
	# connect signals
	pressed.connect(_on_pressed)
	# get the uid of the current scene as a StringName
	current_scene = StringName(ResourceUID.id_to_text(ResourceLoader.get_resource_uid(get_tree().current_scene.scene_file_path)))
	match current_scene:
		level_path:
			text = "Exit Level"
		level_select_path:
			text = "Exit Level Select"
		main_menu_path:
			queue_free()

func _on_pressed() -> void:
	match current_scene:
		level_path:
			SceneManager.load_scene(level_select_path)
			get_parent().get_parent().queue_free()
		level_select_path:
			SceneManager.load_scene(main_menu_path)
			get_parent().get_parent().queue_free()
