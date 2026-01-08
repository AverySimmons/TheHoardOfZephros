class_name Settings
extends CanvasLayer

signal closed()

var _animation_tween: Tween

@onready var color_rect: ColorRect = $Control/ColorRect

func enter_animation() -> void:
	_animation_tween = create_tween()
	
	_animation_tween.tween_method(_set_animation, 0., 1., 0.2)

func exit_animation() -> void:
	if _animation_tween: _animation_tween.kill()
	
	_animation_tween = create_tween()
	_animation_tween.tween_method(_set_animation, 1., 0., 0.2)
	
	await _animation_tween.finished
	closed.emit()
	queue_free()

func _set_animation(val: float) -> void:
	color_rect.material.set_shader_parameter("animation", val)
	$Control.modulate.a = val


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		exit_animation()
