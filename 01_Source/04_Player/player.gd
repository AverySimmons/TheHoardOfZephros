class_name Player
extends CharacterBody2D


signal death()
signal potion_picked_up()
signal potion_used()

var has_potion: bool = false
var input_direction: float = 0


const _SMALL_STRAFE_MAX_VEL: float = 300
const _SMALL_STRAFE_ACC: float = _SMALL_STRAFE_MAX_VEL / 0.1
const _SMALL_IDLE_DEACC: float = _SMALL_STRAFE_MAX_VEL / 0.05

const _BIG_STRAFE_MAX_VEL: float = 250
const _BIG_STRAFE_ACC: float = _BIG_STRAFE_MAX_VEL / 0.3
const _BIG_IDLE_DEACC: float = _BIG_STRAFE_MAX_VEL / 0.15

const _SMALL_FALL_VEL_MAX: float = 750
const _SMALL_FALL_ACC: float = _SMALL_FALL_VEL_MAX / 0.5

const _BIG_FALL_VEL_MAX: float = 1000
const _BIG_FALL_ACC: float = _BIG_FALL_VEL_MAX / 0.5

const _SMALL_JUMP_VEL: float = 700
const _BIG_JUMP_VEL: float = 300

const _BUFFER_JUMP_WINDOW: float = 0.1
const _COYOTE_JUMP_WINDOW: float = 0.1

const _JUMP_CUT: float = 0.5
const _JUMP_GRAVITY_FRACT: float = 0.8

const _BIG_WEIGHT: float = 20.
const _SMALL_WEIGHT: float = 0.

@onready var _potion_area: Area2D = $PotionArea
@onready var _box_area: Area2D = $BoxArea
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _physics_shape: CollisionPolygon2D = $PhysicsShape
@onready var _potion_shape: CollisionShape2D = $PotionArea/PotionShape
@onready var _box_shape: CollisionShape2D = $BoxArea/BoxShape


var _is_big: bool = true

var _buffer_jump_timer: float = 0
var _coyote_jump_timer: float = 0

var _is_jumping = false

var _grow_tween: Tween
var _size: float = 1.

var _potion_timer: float = 0.

var _last_vel: Vector2 = Vector2.ZERO

var _force_timer = 0
var _fall_force = 0

func get_weight(seen: Dictionary) -> float:
	seen[self] = true
	
	var base_weight = _BIG_WEIGHT if _is_big else _SMALL_WEIGHT
	
	var bonus = 0 if _force_timer <= 0 else _fall_force
	_force_timer = 0
	
	return base_weight + bonus * 20 * base_weight

func get_chain(seen: Dictionary) -> void:
	seen[self] = true


func _ready() -> void:
	_potion_area.area_entered.connect(_pickup_potion)

func _physics_process(delta: float) -> void:
	input_direction = Input.get_axis("left", "right")
	
	if Input.is_action_just_pressed("grow"):
		_potion_input()
	if Input.is_action_just_pressed("shrink"):
		_shrink_input()
	
	_strafe_physics(delta)
	_jump_physics()
	_gravity_physics(delta)
	
	_last_vel = velocity
	move_and_slide()
	_handle_collision()
	
	_tick_timers(delta)

func _process(delta: float) -> void:
	_set_shader_velocity(delta)
	_update_walking_particles()

func _potion_input() -> void:
	if has_potion and not _is_big:
		_grow()
		potion_used.emit()
		_potion_timer = 2.
		has_potion = false
	
	else:
		pass

func _shrink_input() -> void:
	if _is_big:
		_shrink()
	
	else:
		pass

func _grow() -> void:
	_is_big = true
	if _grow_tween: 
		_grow_tween.kill()
		$ShrinkParticles.emitting = false
	
	_grow_tween = create_tween().set_parallel()
	_grow_tween.tween_method(_set_size, _size, 1., 0.2)
	_grow_tween.tween_method(_set_ray_size, _size, 1., 0.2)
	
	$Grow.play()
	
	$GrowParticles.emitting = true
	await _grow_tween.finished
	$GrowParticles.emitting = false

func _shrink() -> void:
	_is_big = false
	
	_set_ray_size(0.3)
	
	if _grow_tween: 
		_grow_tween.kill()
		$GrowParticles.emitting = false
	
	_grow_tween = create_tween()
	_grow_tween.tween_method(_set_size, _size, 0.3, 0.2)
	
	$Shrink.play()
	
	$ShrinkParticles.emitting = true
	await _grow_tween.finished
	$ShrinkParticles.emitting = false

func _set_size(val: float) -> void:
	_size = val
	_sprite.material.set_shader_parameter("size", val)
	
	#var points = []
	#points.push_back(Vector2(-94, 0) * val)
	#points.push_back(Vector2(-94, -50) * val)
	#points.push_back(Vector2(-37, -125) * val)
	#points.push_back(Vector2(37, -125) * val)
	#points.push_back(Vector2(94, -50) * val)
	#points.push_back(Vector2(94, 0) * val)
	#_physics_shape.polygon = points
	
	_physics_shape.scale = Vector2.ONE * val
	
	_potion_shape.shape.size = Vector2(182.4, 118) * val
	_potion_area.position.y = -64.8 * val
	_box_shape.shape.size = Vector2(201.6, 138) * val
	_box_area.position.y = -64.8 * val
	
	var wp: GPUParticles2D = $WalkingParticles
	var mat: ParticleProcessMaterial = wp.process_material
	mat.emission_shape_scale.x = 80 * val
	wp.amount_ratio = val

func _set_ray_size(val: float) -> void:
	$RayCasts/CenterCast.position = Vector2(0, -78) * val
	for r:RayCast2D in $RayCasts.get_children(): r.target_position.y = -50 * val

func _update_walking_particles() -> void:
	var wp: GPUParticles2D = $WalkingParticles
	var mat: ParticleProcessMaterial = wp.process_material
	
	mat.direction = Vector3(-sign(velocity.x),0,0)
	wp.emitting = velocity.x != 0 and is_on_floor()
	
	if input_direction == 0 or not is_on_floor():
		$BigWalking.volume_linear = 0
		$SmallWalking.volume_linear = 0
	else:
		if _is_big:
			$BigWalking.volume_linear = 0.1
			$SmallWalking.volume_linear = 0
		else:
			$BigWalking.volume_linear = 0
			$SmallWalking.volume_linear = 0.1
	
	

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
	
	elif not Input.is_action_pressed("jump") and _is_jumping:
		velocity.y *= _JUMP_CUT
		_is_jumping = false

func _gravity_physics(delta: float) -> void:
	var max_vel = _BIG_FALL_VEL_MAX if _is_big else _SMALL_FALL_VEL_MAX
	var acc = _BIG_FALL_ACC if _is_big else _SMALL_FALL_ACC
	
	if _is_jumping:
		acc *= _JUMP_GRAVITY_FRACT
	
	velocity.y = move_toward(velocity.y, max_vel, acc * delta)
	
	if not is_on_floor():
		_force_timer = 0.1
		_fall_force = max(0, velocity.y) / max_vel
	
	if velocity.y >= 0:
		_is_jumping = false

func _jump() -> void:
	_buffer_jump_timer = 0
	_coyote_jump_timer = 0
	
	var vel = _BIG_JUMP_VEL if _is_big else _SMALL_JUMP_VEL
	velocity.y = -vel
	
	_is_jumping = true
	
	if _is_big:
		$BigJump.play()
	else:
		$SmallJump.play()

func _tick_timers(delta: float) -> void:
	_buffer_jump_timer -= delta
	_coyote_jump_timer -= delta
	_potion_timer -= delta
	_force_timer -= delta

func _pickup_potion(potion: Area2D) -> void:
	if has_potion: return
	
	potion_picked_up.emit()
	
	has_potion = true
	potion.pick_up()

func _handle_collision() -> void:
	var cast_hitting = false
	for c: RayCast2D in $RayCasts.get_children():
		if c.is_colliding(): cast_hitting = true
	
	if is_on_floor() and cast_hitting:
		if _is_big:
			_shrink()
			
			if _potion_timer > 0.:
				has_potion = true
				
				$PotionFailed.play()
			
			
			
		else:
			_die()
	
	
	if not _is_big: return
	
	for box in _box_area.get_overlapping_bodies():
		if box is Box:
			var box_dir = global_position.direction_to(box.global_position)
			var push_dir = Vector2(input_direction,0).normalized()
			if box_dir.dot(push_dir) > 0.75 and box_dir.y < 0:
				#print(box_dir.dot(push_dir))
				box.push(input_direction, {})


func _set_shader_velocity(delta: float) -> void:
	var vel_x = velocity.x / (_BIG_STRAFE_MAX_VEL if _is_big else _SMALL_STRAFE_MAX_VEL)
	var vel_y = velocity.y / (_BIG_JUMP_VEL if _is_big else _SMALL_JUMP_VEL);
	
	vel_y = clamp(vel_y, -1, 0.75)
	
	var current = _sprite.material.get_shader_parameter("velocity")
	
	var target = Vector2(vel_x, vel_y)
	
	var speed = 10 if not is_on_floor() else 20
	
	_sprite.material.set_shader_parameter("velocity", current.move_toward(target, speed * delta))

func _die() -> void:
	death.emit()

func _is_turning() -> bool:
	return (velocity.x < 0 and input_direction > 0) or \
			(velocity.x > 0 and input_direction < 0)
