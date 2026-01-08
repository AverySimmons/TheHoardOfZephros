class_name GameManager
extends Node


signal game_finished()
signal switch_music_area2()
signal switch_music_area3()

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var _levels_packed: Array[PackedScene] = [
	preload("uid://bvpeegylbelts"),
	preload("uid://b6y8rkj5ymuj2"),
	preload("uid://du8lnpfefmf6"),
	preload("uid://cpvqqn6b7nfv6"),
	preload("uid://bvx8irclpppjh"),
	preload("uid://6p08okp2oawv"),
	preload("uid://bvyrkf3u1hcoe"),
	preload("uid://byo2oelav2q52"),
]

var _level_count: int = 0
var _current_level: Level


func _ready() -> void:
	_load_level(0)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		_reset_level()


func _load_level(index: int) -> void:
	var level: Level = _levels_packed[index].instantiate()
	
	level.level_complete.connect(_next_level)
	level.player_death.connect(_reset_level)
	
	_current_level = level
	add_child(level)
	
	$Transition.play()
	get_tree().paused = false
	animation_player.play("trans_in")
	await animation_player.animation_finished
	

func _remove_level() -> void:
	$Transition.play()
	get_tree().paused = true
	animation_player.play("trans_out")
	await animation_player.animation_finished
	_current_level.queue_free()
	_current_level = null

func _next_level() -> void:
	_level_count += 1
	if _level_count == 3:
		switch_music_area2.emit()
	elif _level_count == 6:
		switch_music_area3.emit()
	
	await _remove_level()
	if _level_count >= _levels_packed.size():
		game_finished.emit()
	else:
		_load_level(_level_count)

func _reset_level() -> void:
	await _remove_level()
	_load_level(_level_count)
