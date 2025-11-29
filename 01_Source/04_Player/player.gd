class_name Player
extends CharacterBody2D


var has_potion: bool = false
var input_direction: float = 0


const _SMALL_STRAFE_MAX_VEL: float = 200
const _SMALL_STRAFE_ACC: float = _SMALL_STRAFE_MAX_VEL / 0.1
const _SMALL_IDLE_DEACC: float = _SMALL_STRAFE_MAX_VEL / 0.05

const _BIG_STRAFE_MAX_VEL: float = 200
const _BIG_STRAFE_ACC: float = _BIG_STRAFE_MAX_VEL / 0.1
const _BIG_IDLE_DEACC: float = _BIG_STRAFE_MAX_VEL / 0.05

const _SMALL_FALL_VEL_MAX: float = 1000
const _SMALL_FALL_ACC: float = _SMALL_FALL_VEL_MAX / 0.5

const _BIG_FALL_VEL_MAX: float = 1000
const _BIG_FALL_ACC: float = _BIG_FALL_VEL_MAX / 0.5

const _SMALL_JUMP_VEL: float = 250
const _BIG_JUMP_VEL: float = 400

const _BUFFER_JUMP_WINDOW: float = 0.1
const _COYOTE_JUMP_WINDOW: float = 0.1


@onready var _potion_area: Area2D = $PotionArea


var _is_big: bool = true

var _buffer_jump_timer: float = 0
var _coyote_jump_timer: float = 0


func _ready() -> void:
	_potion_area.area_entered.connect(_pickup_potion)

func _physics_process(delta: float) -> void:
	input_direction = Input.get_axis("left", "right")
	
	_potion_input()
	_shrink_input()
	
	_strafe_physics(delta)
	_jump_physics()
	_gravity_physics(delta)
	
	move_and_slide()
	print(velocity)
	_tick_timers(delta)


func _potion_input() -> void:
	if has_potion and not _is_big:
		
		
		_is_big = true
		has_potion = false
	
	else:
		pass

func _shrink_input() -> void:
	if _is_big:
		
		
		_is_big = false
	
	else:
		pass

func _strafe_physics(delta: float) -> void:
	var max_vel = _BIG_STRAFE_MAX_VEL if _is_big else _SMALL_STRAFE_MAX_VEL
	var input_acc = _BIG_STRAFE_ACC if _is_big else _SMALL_STRAFE_ACC
	var deacc = _BIG_IDLE_DEACC if _is_big else _SMALL_IDLE_DEACC
	var acc = input_acc + deacc if _is_turning() else input_acc
	
	if input_direction == 0:
		velocity.x = move_toward(velocity.x, 0, deacc * delta)
	else:
		velocity.x = move_toward(velocity.x, max_vel * input_direction, acc * delta)

func _jump_physics() -> void:
	if is_on_floor():
		_coyote_jump_timer = _COYOTE_JUMP_WINDOW
		
		if Input.is_action_just_pressed("jump") or _buffer_jump_timer > 0:
			_jump()
	
	elif Input.is_action_just_pressed("jump"):
		if _coyote_jump_timer > 0:
			_jump()
		else:
			_buffer_jump_timer = _BUFFER_JUMP_WINDOW

func _gravity_physics(delta: float) -> void:
	var max_vel = _BIG_FALL_VEL_MAX if _is_big else _SMALL_FALL_VEL_MAX
	var acc = _BIG_FALL_ACC if _is_big else _SMALL_FALL_ACC
	
	velocity.y = move_toward(velocity.y, max_vel, acc * delta)

func _jump() -> void:
	_buffer_jump_timer = 0
	_coyote_jump_timer = 0
	
	var vel = _BIG_JUMP_VEL if _is_big else _SMALL_JUMP_VEL
	velocity.y = -vel

func _tick_timers(delta: float) -> void:
	_buffer_jump_timer -= delta
	_coyote_jump_timer -= delta

func _pickup_potion(potion: Area2D) -> void:
	
	
	has_potion = true
	potion.queue_free()

func _is_turning() -> bool:
	return (velocity.x < 0 and input_direction > 0) or \
			(velocity.x > 0 and input_direction < 0)
