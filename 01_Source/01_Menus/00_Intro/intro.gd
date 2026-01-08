class_name Intro
extends Node2D

signal start_pressed()
signal settings_pressed()
signal exit_pressed()

signal music_swap()

var in_anim = false

@onready var camera: Camera2D = $Camera2D
@export var camera_speed = 0

@onready var _start_button: Button = $SecondScene/Parallax2D3/StartButton
@onready var _settings_button: Button = $SecondScene/Parallax2D3/SettingsButton
@onready var _exit_button: Button = $SecondScene/Parallax2D3/ExitButton

func _ready() -> void:
	_start_button.pressed.connect(_start_pressed)
	_settings_button.pressed.connect(_settings_pressed)
	_exit_button.pressed.connect(_exit_pressed)
	_start_button.mouse_entered.connect(_hover)
	_settings_button.mouse_entered.connect(_hover)
	_exit_button.mouse_entered.connect(_hover)

func _hover() -> void:
	$MenuHover.play()

func _select() -> void:
	$MenuSelect.play()

func _signal_music_swap() -> void:
	music_swap.emit()

func _start_pressed() -> void:
	if in_anim: return
	_select()
	
	in_anim = true
	$ExitPlayer.play("exit")
	await $ExitPlayer.animation_finished
	
	start_pressed.emit()

func _settings_pressed() -> void:
	if in_anim: return
	_select()
	
	settings_pressed.emit()

func _exit_pressed() -> void:
	if in_anim: return
	_select()
	
	await get_tree().create_timer(0.5).timeout
	
	exit_pressed.emit()


func _process(delta: float) -> void:
	camera.position.x += camera_speed * delta
