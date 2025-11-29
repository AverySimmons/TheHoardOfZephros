class_name GameManager
extends Node

signal settings_pressed()


@onready var _levels_packed: Array[PackedScene] = [
	preload("uid://bb7dpd3goopy5")
]


var _level_count: int = 0
var _current_level: Level


func _ready() -> void:
	_load_level(0)


func _load_level(index: int) -> void:
	var level: Level = _levels_packed[index].instantiate()
	
	_current_level = level
	add_child(level)

func _remove_level() -> void:
	_current_level.queue_free()
	_current_level = null
