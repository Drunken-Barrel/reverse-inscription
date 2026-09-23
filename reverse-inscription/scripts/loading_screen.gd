extends CanvasLayer

# signals
signal loading_screen_ready_signal

# pre-load all directories
@onready var PlayAnimation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	await PlayAnimation.animation_finished
	loading_screen_ready_signal.emit()

func _on_progress_changed(_new_value: float) -> void:
	pass

func _on_loading_finished() -> void:
	PlayAnimation.play_backwards("transition")
	await PlayAnimation.animation_finished
	queue_free()
