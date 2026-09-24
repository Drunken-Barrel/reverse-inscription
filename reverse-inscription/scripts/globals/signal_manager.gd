extends Node

# signals
@warning_ignore("unused_signal")
signal begin_combat_signal
signal end_combat_signal
@warning_ignore("unused_signal")
signal output_attack_signal
@warning_ignore("unused_signal")
signal reset_signal
@warning_ignore("unused_signal")
signal setup_level_signal
@warning_ignore("unused_signal")
signal combat_results_signal

# variables
var lanes = Array()

func add_lane(lane) -> void:
	lanes.append(lane)
	print(lanes)

func remove_lane(lane) -> void:
	lanes.erase(lane)
	print(lanes)
	if lanes == Array():
		end_combat_signal.emit()
