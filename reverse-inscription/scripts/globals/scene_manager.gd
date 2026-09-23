extends Node

# signals
signal progress_changed_signal
signal load_finished_signal

# variables
var loading_screen: PackedScene = preload("uid://fercaxx7jnee")
var loaded_resource: PackedScene
var level: int
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true

func _ready() -> void:
	set_process(false)

func load_scene(_scene_path: String,_level: int = 0) -> void:
	scene_path = _scene_path
	level = _level
	# create the loading screen and display it
	var new_loading_screen = loading_screen.instantiate()
	add_child(new_loading_screen)
	progress_changed_signal.connect(new_loading_screen._on_progress_changed)
	load_finished_signal.connect(new_loading_screen._on_loading_finished)
	# wait until the loading screen has fully covered the screen and begin load
	await new_loading_screen.loading_screen_ready_signal
	start_load()

func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path,"",use_sub_threads)
	if state == OK:
		set_process(true)

func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path,progress)
	progress_changed_signal.emit(progress[0])
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			# if a level number was defined pass it onto the loaded resource
			if level > 0:
				loaded_resource.level = level
			get_tree().change_scene_to_packed(loaded_resource)
			load_finished_signal.emit()
