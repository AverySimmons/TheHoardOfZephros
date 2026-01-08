extends Node2D

@export var right_ray_on: bool = true
@export var left_ray_on: bool = true
@export var stop_percent: float = 0.

@export var weight_need: float = 12.
@export var speed: float = 200.

const _HEIGHT: float = 384.0

@onready var _body: CharacterBody2D = $CharacterBody2D
@onready var _left_ray: RayCast2D = $LeftRay
@onready var _right_ray: RayCast2D = $RightRay
@onready var _weight_area: Area2D = $CharacterBody2D/WeightArea
@onready var _move_sprite: Sprite2D = $CharacterBody2D/MoveSprite


var _cur_h: float = 1.

var _was_compress = false

func _physics_process(delta: float) -> void:
	
	var total_weight = _get_total_weight()
	var th = 1. - (_body.position.y + _HEIGHT / 2.) / _HEIGHT
	_cur_h = 1. - (th - stop_percent) / (1. - stop_percent)
	_body.velocity.y += (total_weight - weight_need) * speed * delta
	_body.velocity.y -= _body.velocity.y * delta
	
	if total_weight < weight_need and _was_compress and _body.velocity.y < 0:
		$Decompress.play()
		_was_compress = false
	elif total_weight > weight_need and not _was_compress and _body.velocity.y > 0:
		$Compress.play()
		_was_compress = true
	
	_body.move_and_slide()
	
	th = 1. - (_body.position.y + _HEIGHT / 2.) / _HEIGHT
	_cur_h = 1. - (th - stop_percent) / (1. - stop_percent)
	
	if _cur_h > 1.:
		_body.position.y = _HEIGHT * 0.5 - _HEIGHT * stop_percent
		_body.velocity.y = 0
	
	if _cur_h < 0.:
		if _body.velocity.y < -100.:
			_launch()
		_body.position.y = -_HEIGHT * 0.5
		_body.velocity.y = 0

func _process(_delta: float) -> void:
	_move_sprite.material.set_shader_parameter("percent", _cur_h)


func _launch() -> void:
	var targets = {}
	
	var left_hit = _left_ray.get_collider()
	var right_hit = _right_ray.get_collider()
	
	for b in _weight_area.get_overlapping_bodies():
		if ((b != left_hit or not left_ray_on) and (b != right_hit or not right_ray_on)) or _cur_h > 0.1:
			b.get_chain(targets)
	
	var target_num = targets.size()
	var vel = _body.velocity.y
	
	# print(targets.keys())
	
	for t in targets.keys():
		if t is Player:
			t.velocity.y += vel / float(target_num)
		else:
			t.velocity.y += vel / float(target_num) * 2.
	

func _get_total_weight() -> float:
	var total_weight = 0.
	var seen_dict = {}
	
	var left_hit = _left_ray.get_collider()
	var right_hit = _right_ray.get_collider()
	
	for b in _weight_area.get_overlapping_bodies():
		if ((b != left_hit or not left_ray_on) and (b != right_hit or not right_ray_on)) or _cur_h > 0.1:
			total_weight += b.get_weight(seen_dict)
	
	return total_weight
