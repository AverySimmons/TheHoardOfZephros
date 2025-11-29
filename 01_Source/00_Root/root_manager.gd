class_name RootManager
extends Node

# intro, main menu, settings, outro

@onready var _main_menu_packed: PackedScene = preload("uid://b16mh5mlxnudj")
@onready var _settings_packed: PackedScene = preload("uid://cskr4rvs5n1g8")
@onready var _intro_packed: PackedScene = preload("uid://d0cse28evhml0")
@onready var _outro_packed: PackedScene = preload("uid://bg7lyayy7ulcj")
@onready var _game_manager_packed: PackedScene = preload("uid://cq7cu7mh22j3b")

var _current_child: Node
var _settings_node: Settings

func _ready() -> void:
	_add_main_menu()


func _start_pressed() -> void:
	_remove_current_child()
	_add_game_manager()

func _open_settings() -> void:
	get_tree().paused = true
	_add_settings()

func _close_settings() -> void:
	get_tree().paused = false
	_remove_settings()

func _exit_pressed() -> void:
	_exit()

func _intro_finished() -> void:
	_remove_current_child()
	_add_main_menu()

func _outro_finished() -> void:
	_exit()


func _exit() -> void:
	get_tree().quit()

func _remove_current_child() -> void:
	_current_child.queue_free()
	_current_child = null

func _add_main_menu() -> void:
	var main_menu: MainMenu = _main_menu_packed.instantiate()
	
	main_menu.start_pressed.connect(_start_pressed)
	main_menu.settings_pressed.connect(_open_settings)
	main_menu.exit_pressed.connect(_exit_pressed)
	
	_current_child = main_menu
	add_child(main_menu)

func _add_settings() -> void:
	pass

func _remove_settings() -> void:
	pass

func _add_intro() -> void:
	pass

func _add_outro() -> void:
	pass

func _add_game_manager() -> void:
	var game_manager: GameManager = _game_manager_packed.instantiate()
	
	game_manager.settings_pressed.connect(_add_settings)
	
	_current_child = game_manager
	add_child(game_manager)
