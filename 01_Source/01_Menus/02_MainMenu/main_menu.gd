class_name MainMenu
extends Node2D

signal start_pressed()
signal settings_pressed()
signal exit_pressed()

@onready var _start_button: Button = $StartButton
@onready var _settings_button: Button = $SettingsButton
@onready var _exit_button: Button = $ExitButton


func _ready() -> void:
	_start_button.pressed.connect(_start_pressed)
	_settings_button.pressed.connect(_settings_pressed)
	_exit_button.pressed.connect(_exit_pressed)


func _start_pressed() -> void:
	start_pressed.emit()

func _settings_pressed() -> void:
	settings_pressed.emit()

func _exit_pressed() -> void:
	exit_pressed.emit()
