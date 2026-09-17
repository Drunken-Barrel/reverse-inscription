extends Button

# start combat on click
func _on_pressed() -> void:
	SignalManager.begin_combat_signal.emit()
