class_name RootManager
extends Node

# intro, main menu, settings, outro

@onready var _settings_packed: PackedScene = preload("uid://cskr4rvs5n1g8")
@onready var _intro_packed: PackedScene = preload("uid://d0cse28evhml0")
@onready var _outro_packed: PackedScene = preload("uid://bg7lyayy7ulcj")
@onready var _game_manager_packed: PackedScene = preload("uid://cq7cu7mh22j3b")

var _intro: Intro
var _game_manager: GameManager
var _outro
var _settings_node: Settings




func _ready() -> void:
	_add_intro()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("escape") and not _settings_node:
		_open_settings()


func _start_pressed() -> void:
	_switch_to_area1_music()
	_add_game_manager()
	_intro.queue_free()

func _open_settings() -> void:
	get_tree().paused = true
	_add_settings()

func _close_settings() -> void:
	get_tree().paused = false

func _exit_pressed() -> void:
	_exit()


func _exit() -> void:
	get_tree().quit()

func _add_settings() -> void:
	var settings: Settings = _settings_packed.instantiate()
	
	settings.closed.connect(_close_settings)
	
	_settings_node = settings
	add_child(settings)
	_settings_node.enter_animation()

func _remove_settings() -> void:
	pass

func _add_intro() -> void:
	var intro: Intro = _intro_packed.instantiate()
	
	intro.start_pressed.connect(_start_pressed)
	intro.settings_pressed.connect(_add_settings)
	intro.exit_pressed.connect(_exit_pressed)
	intro.music_swap.connect(_switch_to_menu_music)
	
	_intro = intro
	add_child(intro)

func _add_outro() -> void:
	
	var outro = _outro_packed.instantiate()
	$OutroMusic.play()
	$Area3Music.stop()
	add_child(outro)
	_game_manager.queue_free()

func _add_game_manager() -> void:
	var game_manager: GameManager = _game_manager_packed.instantiate()
	
	game_manager.switch_music_area2.connect(_switch_to_area2_music)
	game_manager.switch_music_area3.connect(_switch_to_area3_music)
	game_manager.game_finished.connect(_add_outro)
	
	_game_manager = game_manager
	add_child(game_manager)

func _switch_to_menu_music() -> void:
	var t = create_tween()
	t.tween_property($IntroMusic, "volume_linear", 0, 0.4)
	
	$MenuMusic.play()
	
	await t.finished
	$IntroMusic.stop()

func _switch_to_area1_music() -> void:
	var t = create_tween()
	t.tween_property($MenuMusic, "volume_linear", 0, 0.4)
	
	$Area1Music.play()
	
	await t.finished
	$MenuMusic.stop()

func _switch_to_area2_music() -> void:
	var t = create_tween()
	t.tween_property($Area1Music, "volume_linear", 0, 0.4)
	
	$Area2Music.play()
	
	await t.finished
	$Area1Music.stop()

func _switch_to_area3_music() -> void:
	var t = create_tween()
	t.tween_property($Area2Music, "volume_linear", 0, 0.4)
	
	$Area3Music.play()
	
	await t.finished
	$Area2Music.stop()
