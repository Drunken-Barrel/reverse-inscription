extends Node

# signals
signal progress_changed_signal
signal load_finished_signal

# variables
var LoadingScreen: PackedScene = preload("uid://fercaxx7jnee")
var PauseScreen: PackedScene = preload("uid://bl0jxxiekg0nr")
var LoadedResource: PackedScene
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
	var NewLoadingScreen = LoadingScreen.instantiate()
	add_child(NewLoadingScreen)
	progress_changed_signal.connect(NewLoadingScreen._on_progress_changed)
	load_finished_signal.connect(NewLoadingScreen._on_loading_finished)
	# wait until the loading screen has fully covered the screen and begin load
	await NewLoadingScreen.loading_screen_ready_signal
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
			LoadedResource = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(LoadedResource)
			# if a level number was defined pass it onto the level
			if level > 0:
				await get_tree().create_timer(0.1).timeout
				SignalManager.setup_level_signal.emit(level)
			# alert the loading screen that the level is loaded and to fade out
			load_finished_signal.emit()

# if the escape key is pressed open up a pause screen or close the current one
func _input(event):
	if event.is_action_pressed("ui_escape"):
		# check if there is currently a pause screen active
		if !has_node("PauseScreen"):
			# create a pause screen
			var NewPauseScreen = PauseScreen.instantiate()
			add_child(NewPauseScreen)
		else:
			# remove the pause screen
			$PauseScreen.queue_free()
