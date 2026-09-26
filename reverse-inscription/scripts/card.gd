extends Control
# signals
signal update_health_signal
signal update_strength_signal

# pre-load all directories
@onready var CardName: Label = $CardName
@onready var HealthChecker: Area2D = $HealthChecker
@onready var StrengthChecker: Area2D = $StrengthChecker
@onready var AbilityChecker: Area2D = $AbilityChecker
@onready var CardArt: Sprite2D = $CardArt
@onready var  PlayAnimation: AnimationPlayer = $AnimationPlayer

# variables
@export var card_name: String = "filler":
	set(value):
		card_name = value
		# update display
		if CardName != null:
			CardName.text = value
		else:
			$CardName.text = value
# tracks the lane the card is in, starting from 0
@export var lane: int = 0
# 0 is bottom and 1 is top
@export var side: int = 0
var health: int = 0:
	set(value):
		# cap minimum health at 0
		if value < 0:
			value = 0
		# if equipped send a signal to the equipped block to change value
		if health_block != null:
			update_health_signal.emit(value)
		health = value
var strength: int = 0:
	set(value):
		# cap minimum strength at 0
		if value < 0:
			value = 0
		# if equipped send a signal to the equipped block to change value
		if strength_block != null:
			update_strength_signal.emit(value)
		strength = value
var ability: int = AbilityLister.AbilityList.NULL
var health_block: Node = null
var strength_block: Node = null
var ability_block: Node = null

func _ready() -> void:
	# connect signals
	SignalManager.begin_combat_signal.connect(_attack_if_first)
	SignalManager.output_attack_signal.connect(_take_damage)
	# once combat is over send results to level
	SignalManager.end_combat_signal.connect(func():SignalManager.combat_results_signal.emit(lane,side,health,strength,ability))
	$HealthChecker.area_entered.connect(_on_health_checker_area_entered)
	$StrengthChecker.area_entered.connect(_on_strength_checker_area_entered)
	$AbilityChecker.area_entered.connect(_on_ability_checker_area_entered)
	$HealthChecker.area_exited.connect(_on_health_checker_area_exited)
	$StrengthChecker.area_exited.connect(_on_strength_checker_area_exited)
	$AbilityChecker.area_exited.connect(_on_ability_checker_area_exited)
	# update display if the card is on the top side
	if side == 1:
		CardArt.flip_v = true

# used to start combat, as cards will attack when hit unless they are on 0 health
func _attack_if_first() -> void:
	if side == 0:
		attack()
		SignalManager.add_lane(lane)

func attack() -> void:
	# use the correct animation based on side
	if side == 0:
		PlayAnimation.play("attack_up")
	else:
		PlayAnimation.play("attack_down")
	# wait until the right part of the animation then send the attack signal
	await get_tree().create_timer(0.5).timeout
	SignalManager.output_attack_signal.emit(lane,side,strength)

func _take_damage(attacker_lane: int,attacker_side: int,attacker_strength: int) -> void:
	# take damage if the signal was sent from the directly opposing card
	if attacker_side != side and attacker_lane == lane:
		health -= attacker_strength
		# relatiate if alive or end the lane's combat if not
		if health > 0:
			attack()
		else:
			SignalManager.remove_lane(lane)

# following 6 functions manage stat blocks entering and exiting stat checkers
func _on_health_checker_area_entered(area: Area2D) -> void:
	# check if the area is a value holding stat block
	if area.name.contains("StatBlock"):
		if area.max_stat_number >= 0:
			# copy the stat from it and save it
			health = area.stat_number
			health_block = area
			set_equipped(HealthChecker,true)
			# connect the stat update signal to the corresponding stat
			health_block.update_stat_number_signal.connect(_update_health)

func _on_strength_checker_area_entered(area: Area2D) -> void:
	# check if the area is a value holding stat block
	if area.name.contains("StatBlock"):
		if area.max_stat_number >= 0:
			# copy the stat from it and save it
			strength = area.stat_number
			strength_block = area
			set_equipped(StrengthChecker,true)
			# connect the stat update signal to the corresponding stat
			strength_block.update_stat_number_signal.connect(_update_strength)

func _on_ability_checker_area_entered(area: Area2D) -> void:
	# check if the area is an ability holding stat block
	if area.name.contains("StatBlock"):
		if area.ability != AbilityLister.AbilityList.NULL:
			# copy the ability from it and save it
			ability = area.ability
			ability_block = area
			set_equipped(AbilityChecker,true)

func _on_health_checker_area_exited(area: Area2D) -> void:
	# check if the area is the equipped stat block
	if area == health_block:
		# disconnect the attached signal
		if health_block.update_stat_number_signal.is_connected(_update_health):
			health_block.update_stat_number_signal.disconnect(_update_health)
		# reset stat to 0 and forget block
		health_block = null
		set_equipped(HealthChecker,false)
		health = 0

func _on_strength_checker_area_exited(area: Area2D) -> void:
	# check if the area is the equipped stat block
	if area == strength_block:
		# disconnect the attached signal
		if strength_block.update_stat_number_signal.is_connected(_update_strength):
			strength_block.update_stat_number_signal.disconnect(_update_strength)
		# reset stat to 0 and forget block
		strength_block = null
		set_equipped(StrengthChecker,false)
		strength = 0

func _on_ability_checker_area_exited(area: Area2D) -> void:
	# check if the area is the equipped stat block
	if area == ability_block:
		# reset stat to 0 and forget block
		ability_block = null
		set_equipped(AbilityChecker,false)
		ability = AbilityLister.AbilityList.NULL

# the following 2 functions manage updating health and strength
func _update_health(value) -> void:
	health = value

func _update_strength(value) -> void:
	strength = value

# function to more cleanly change collision layers on checkers, takes the path and status as arguments
func set_equipped(node: Area2D,equipped: bool) -> void:
	node.set_collision_layer_value(1,!equipped)
	node.set_collision_mask_value(1,!equipped)
	node.set_collision_layer_value(2,equipped)
	node.set_collision_mask_value(2,equipped)
