extends Control

# variables
var dragging = false
var cursor_offset = Vector2.ZERO
var level: int

func _ready() -> void:
	# get the right texture for the current level
	match level:
		1:
			$TextureRect.texture = load("uid://n30ho8l7enow")

func _gui_input(event: InputEvent) -> void:
	# check if the input was a left click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# check if it was just pressed
		if event.pressed:
			# set dragging to true and record the mouse offset
			dragging = true
			cursor_offset = global_position - get_global_mouse_position()
		else:
			dragging = false
	# follow the mouse if it moves
	if event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() + cursor_offset
	# consume the input
	accept_event()
