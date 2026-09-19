extends Button

func _ready():
	# connect signals
	pressed.connect(_on_pressed)

# reset stat blocks on click
func _on_pressed() -> void:
	SignalManager.reset_stat_block_signal.emit()
