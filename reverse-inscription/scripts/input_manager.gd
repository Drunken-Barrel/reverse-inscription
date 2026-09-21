extends Node

var hovered_stat_blocks: Array = []

func register_stat_block(stat_block) -> void:
	if not hovered_stat_blocks.has(stat_block):
		hovered_stat_blocks.append(stat_block)

func unregister_stat_block(obj) -> void:
	hovered_stat_blocks.erase(obj)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if hovered_stat_blocks.size() > 0:
			# Interact ONLY with the topmost object
			var top_object = hovered_stat_blocks[0]
			if is_instance_valid(top_object) and top_object.has_method("interact"):
				top_object.interact(event)
