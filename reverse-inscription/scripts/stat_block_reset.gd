extends Button

# variables
var combat_active = false

func _ready():
	# connect signals
	pressed.connect(_on_pressed)
	SignalManager.begin_combat_signal.connect(func(): combat_active = true)
	SignalManager.end_combat_signal.connect(func(): combat_active = false)

# reset stat blocks on click
func _on_pressed() -> void:
	if !combat_active:
		SignalManager.reset_signal.emit()
