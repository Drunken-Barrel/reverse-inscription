extends Node

# pre-load all directories
@onready var Side0: BoxContainer = $GameBoard/Side0
@onready var Side1: BoxContainer = $GameBoard/Side1
@onready var StatBlockHolder: Node = $StatBlockHolder

# variables
var level: int
var level_information: Resource
var Card: PackedScene = preload("uid://bhsldu4ldcyfx")
var StatBlock: PackedScene = preload("uid://cnjeco5r213ms")
var min_stat_block_x: int
@onready var max_stat_block_x: int = get_viewport().size.x - 30
var min_stat_block_y: int = 100
var stat_block_spacing: int = 75
var combat_results: Dictionary[Vector2i,Dictionary]

func _ready() -> void:
	# connect signals
	SignalManager.setup_level_signal.connect(_on_level_setup)
	SignalManager.combat_results_signal.connect(_receive_combat_results)

func _on_level_setup(_level) -> void:
	level = _level
	# define the resource for this level
	match level:
		1:
			level_information = load("uid://c4nwusowkpiu0")
	# add as many cards as there are lanes to both sides, changing their lane and side variables to match
	for i in range(level_information.total_lanes):
		var NewCard = Card.instantiate()
		NewCard.lane = i
		NewCard.side = 0
		# set the name to contain Card for readability while still being unique
		NewCard.name = "Card" + str(i)
		Side0.add_child(NewCard)
	for i in range(level_information.total_lanes):
		var NewCard = Card.instantiate()
		NewCard.lane = i
		NewCard.side = 1
		# set the name to contain Card for readability while still being unique
		NewCard.name = "Card" + str(i)
		Side1.add_child(NewCard)
	# set the minimum stat block x to the number of lanes times 250 because cards are 250 wide
	min_stat_block_x = level_information.total_lanes * 250
	# make a variable for tracking the ordinal position of stat blocks
	var ordinal_position = 0
	# add every stat block
	for stat_block in level_information.stat_blocks:
		var NewStatBlock = StatBlock.instantiate()
		# assign variables from the level information
		NewStatBlock.max_stat_number = stat_block["value"]
		NewStatBlock.ability = stat_block["ability"]
		# move into position by applying the matching offset for its ordinal position, looping downwards when x exeeds the maximun
		var y_pos = min_stat_block_y
		var x_pos = min_stat_block_x + stat_block_spacing * ordinal_position
		while x_pos > max_stat_block_x:
			x_pos -= max_stat_block_x - min_stat_block_x
			y_pos += stat_block_spacing
		NewStatBlock.global_position = Vector2(x_pos,y_pos)
		# set the name to contain StatBlock for readability while still being unique
		NewStatBlock.name = "StatBlock" + str(ordinal_position)
		StatBlockHolder.add_child(NewStatBlock)
		# update the ordinal position for the next stat block
		ordinal_position += 1

# function to save each card's combat results to a dictionary of results
func _receive_combat_results(card_lane,card_side,card_health,card_strength,card_ability) -> void:
	combat_results.set(Vector2i(card_lane,card_side),{
		"health": card_health,
		"strength": card_strength,
		"ability": card_ability
	})
	# if all combat results have been received check if the results match the solution
	if combat_results.size() == level_information.total_lanes * 2:
		_check_win()

# checks if the combat result matches the solution after combat finishes
func _check_win() -> void:
	if level_information.solution.recursive_equal(combat_results,0):
		print("win")
	else:
		print("lose")
	combat_results.clear()
