extends Button

# variables
var LevelGoal: PackedScene
var level_goal_active: bool = false

func _ready() -> void:
	# connect signals
	pressed.connect(_on_pressed)
	SignalManager.setup_level_signal.connect(_on_level_setup)

func _on_level_setup(level) -> void:
	# get the right level goal
	match level:
		1:
			LevelGoal = preload("uid://crtg47lqvod8e")

func _on_pressed():
	# check if there is currently a level goal
		if !level_goal_active:
			level_goal_active = true
			# create a pause screen
			var NewLevelGoal = LevelGoal.instantiate()
			add_child(NewLevelGoal)
			# update the text on the button to match the state
			text = "Close level goal"
		else:
			level_goal_active = false
			# remove the pause screen
			$LevelGoal.queue_free()
			# update the text on the button to match the state
			text = "Open level goal"
