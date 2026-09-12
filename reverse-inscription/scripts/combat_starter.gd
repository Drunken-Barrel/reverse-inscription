extends Button

func _on_pressed() -> void:
	PvpManager.begin_combat_signal.emit()
