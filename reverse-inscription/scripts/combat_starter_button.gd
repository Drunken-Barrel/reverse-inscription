extends Button

# variables
var usable = true

func _ready():
	# connect signals
	pressed.connect(_on_pressed)
	SignalManager.reset_signal.connect(func(): usable = true)

# start combat on click
func _on_pressed() -> void:
	if usable:
		usable = false
		SignalManager.begin_combat_signal.emit()
