extends Control

# pre-load all directories
@onready var CardName: Label = $CardName
@onready var CardArt: Sprite2D = $CardArt
@onready var Health: Label = $Health
@onready var Strength: Label = $Strength
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
@export var lane: int = 0:
	set(value):
		lane = value
		# move into position (I'll figure it out later)
@export var side: int = 0:
	set(value):
		side = value
		# move into position (I'll figure it out later)
@export var max_health: int = 0:
	set(value):
		max_health = value
		# match heath to max health to be prepared for combat (max health can only be changed before combat)
		health = value
@export var health: int = 0:
	set(value):
		if value < 0:
			value = 0
			# do dying things
		health = value
		# update display
		if Health != null:
			Health.text = "HP: " + str(health) + "/" + str(max_health)
		else:
			$Health.text = "HP: " + str(health) + "/" + str(max_health)
@export var strength: int = 0:
	set(value):
		strength = value
		# update display
		if Strength != null:
			Strength.text = "STR: " + str(strength)
		else:
			$Strength.text = "STR: " + str(strength)
@export var ability: String = "empty":
	set(value):
		ability = value
		# update display

func _ready() -> void:
	PvpManager.begin_combat_signal.connect(attack_if_first)
	PvpManager.output_attack_signal.connect(take_damage)
	if side == 1:
		CardArt.flip_v = true

func attack_if_first() -> void:
	if side == 0:
		attack()

func attack() -> void:
	if side == 0:
		PlayAnimation.play("attack_up")
	else:
		PlayAnimation.play("attack_down")
	await get_tree().create_timer(0.5).timeout
	PvpManager.output_attack_signal.emit(lane,side,strength)

func take_damage(attacker_lane: int,attacker_side: int,attacker_strength: int) -> void:
	if attacker_side != side and attacker_lane == lane:
		health -= attacker_strength
		if health > 0:
			attack()
