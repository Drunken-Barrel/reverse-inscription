extends Area2D
# signals
signal update_stat_number_signal

# pre-load all directories
@onready var StatNumber: Label = $StatNumber

# variables
# defaults to -1 because the display only updates on change and setting it from 0 to 0 doesn't count as a change
@export var max_stat_number: int = -1:
	set(value):
		max_stat_number = value
		# also sets the stat number to match
		stat_number = value
@export var stat_number: int = -1:
	set(value):
		stat_number = value
		# if equipped and set to max send a signal to the equipped card to change value
		if user != null and value == max_stat_number:
			update_stat_number_signal.emit(value)
		# update display
		if StatNumber != null:
			StatNumber.text = str(value)
		else:
			$StatNumber.text = str(value)
# if ability is null it is a number block, otherwise it is an ability block
@export var ability: String = "null"
var dragging: bool = false
var user: Node = null

func _ready() -> void:
	# connect signals
	input_event.connect(_on_input_event)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	SignalManager.reset_stat_block_signal.connect(_reset)

func _process(_delta: float) -> void:
	# move to the cursor position when being dragged
	if dragging:
		global_position = get_global_mouse_position()
	# if in use move to the position of the user
	elif user != null:
		global_position = user.global_position

# handles mouse inputs
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
		else:
			dragging = false

# function called when the card this is attached to sends a health update signal
func _update_health(value: int):
	if value != stat_number:
		stat_number = value

# function called when the card this is attached to sends a strength update signal
func _update_strength(value: int):
	if value != stat_number:
		stat_number = value

func _on_area_entered(area: Area2D) -> void:
	# define the parent
	var parent = area.get_parent()
	# check if the area has a parent
	if parent != null:
		# check if the area is a child of a card
		if parent.name.contains("Card") and parent is Control:
			# save the current user
			user = area
			set_equipped(true)
			# check if the area is a health or strength slot and connect the matching signal if so
			if area.name.contains("HealthChecker"):
				parent.update_health_signal.connect(_update_health)
			elif area.name.contains("StrengthChecker"):
				parent.update_strength_signal.connect(_update_strength)

func _on_area_exited(area: Area2D) -> void:
	# check if it left the user's area
	if area == user:
		# define the parent
		var parent = area.get_parent()
		# disconnect any connected signals
		if parent.update_health_signal.is_connected(_update_health):
			parent.update_health_signal.disconnect(_update_health)
		if parent.update_strength_signal.is_connected(_update_strength):
			parent.update_strength_signal.disconnect(_update_strength)
		# forget the user
		user = null
		set_equipped(false)

# function to more cleanly change collision layers
func set_equipped(equipped: bool) -> void:
	set_collision_layer_value(1,!equipped)
	set_collision_mask_value(1,!equipped)
	set_collision_layer_value(2,equipped)
	set_collision_mask_value(2,equipped)

func _reset():
	stat_number = max_stat_number
