extends Resource
class_name LevelInformation

@export var total_lanes: int
@export var stat_blocks: Array = [
	{
		"value": 0,
		"ability": AbilityLister.AbilityList.NULL
	}
]
@export var solution: Dictionary[Vector2i,Dictionary] = {
	Vector2i(0,0): {
		"health": 0,
		"strength": 0,
		"ability": AbilityLister.AbilityList.NULL
	}
}
