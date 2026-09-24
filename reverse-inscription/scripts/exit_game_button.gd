extends Button

func _ready() -> void:
	# connect signals
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	get_tree().quit()
