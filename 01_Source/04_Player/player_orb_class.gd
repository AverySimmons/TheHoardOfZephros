extends CharacterBody2D

var _start_pos: Vector2

func _ready() -> void:
	_start_pos = position

func _physics_process(delta: float) -> void:
	velocity = position.direction_to(_start_pos) * 10000 * delta
	
	move_and_slide()
