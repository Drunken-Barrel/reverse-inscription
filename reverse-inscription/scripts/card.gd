extends Control
# signals
signal update_health_signal
signal update_strength_signal

# pre-load all directories
@onready var CardName: Label = $CardName
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
@export var lane: int = 0:
	set(value):
		lane = value
		# move into position (I'll figure it out later)
# 0 is bottom and 1 is top
@export var side: int = 0:
	set(value):
		side = value
		# move into position (I'll figure it out later)
@export var health: int = 0:
	set(value):
		# cap minimum health at 0
		if value < 0:
			value = 0
		update_health_signal.emit(value)
		health = value
@export var strength: int = 0:
	set(value):
		# cap minimum strength at 0
		if value < 0:
			value = 0
		update_strength_signal.emit(value)
		health = value
@export var ability: String = "null":
	set(value):
		ability = value
var health_block: Node = null
var strength_block: Node = null
var ability_block: Node = null

func _ready() -> void:
	# connect signals
	SignalManager.begin_combat_signal.connect(_attack_if_first)
	SignalManager.output_attack_signal.connect(_take_damage)
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
		# relatiate if alive
		if health > 0:
			attack()

func _on_health_checker_area_entered(area: Area2D) -> void:
	# check if the area is a stat block
	if area.name.contains("StatBlock"):
		# copy the stat from it and save it
		health = area.stat_number
		health_block = area

func _on_strength_checker_area_entered(area: Area2D) -> void:
	# check if the area is a stat block
	if area.name.contains("StatBlock"):
		# copy the stat from it and save it
		strength = area.stat_number
		strength_block = area

func _on_ability_checker_area_entered(area: Area2D) -> void:
	# check if the area is a stat block
	if area.name.contains("StatBlock"):
		# copy the ability from it and save it
		ability = area.ability
		ability_block = area

func _on_health_checker_area_exited(area: Area2D) -> void:
	# check if the area is the equipped stat block
	if area == health_block:
		# reset stat to 0 and forget block
		health = 0 
		health_block = null

func _on_strength_checker_area_exited(area: Area2D) -> void:
	# check if the area is the equipped stat block
	if area == strength_block:
		# reset stat to 0 and forget block
		strength = 0 
		strength_block = null

func _on_ability_checker_area_exited(area: Area2D) -> void:
	# check if the area is the equipped stat block
	if area == ability_block:
		# reset stat to 0 and forget block
		ability = "null"
		ability_block = null
