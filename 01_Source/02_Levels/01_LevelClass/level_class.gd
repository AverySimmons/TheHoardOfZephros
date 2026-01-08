class_name Level
extends Node2D


signal level_complete()
signal player_death()


@onready var _bottom_right: Marker2D = $BottomRight
@onready var _top_left: Marker2D = $TopLeft

@onready var _camera = $Camera2D
@onready var _player: Player = $Player
@onready var _treasure_node: Node2D = $Treasure
@onready var _door: Area2D = $Door
@onready var _ui_ap: AnimationPlayer = $CanvasLayer/AnimationPlayer


@onready var player_death_packed = preload("uid://dnrqw5k8tovsn")

var _treasure_count: int = 0

func _ready() -> void:
	_player.death.connect(_player_death)
	_player.potion_picked_up.connect(_potion_picked_up)
	_player.potion_used.connect(_potion_used)
	_door.area_entered.connect(_exit_attempt)
	
	var br = _bottom_right.global_position
	var tl = _top_left.global_position
	
	_camera.limit_bottom = br.y
	_camera.limit_right = br.x
	_camera.limit_top = tl.y
	_camera.limit_left = tl.x
	
	_camera.global_position = _player.global_position
	
	for treasure: Treasure in _treasure_node.get_children():
		treasure.collected.connect(_treasure_collected)
		_treasure_count += 1



func _physics_process(delta: float) -> void:
	var camera_inp = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
	
	if camera_inp != Vector2.ZERO:
		_camera.global_position = _camera.get_screen_center_position()
		_camera.global_position += camera_inp * 900. * delta
	
	elif _player:
		_camera.global_position = _camera.global_position.lerp(_player.global_position, 7.5 * delta)
	

func _exit_attempt(_area: Area2D) -> void:
	if _treasure_count > 0: return
	
	level_complete.emit()

func _treasure_collected() -> void:
	_treasure_count -= 1
	
	if _treasure_count == 0:
		_door.open()

func _player_death() -> void:
	
	var player_pos = _player.global_position
	var death_anim = player_death_packed.instantiate()
	
	death_anim.global_position = player_pos
	_player.call_deferred("queue_free")
	
	add_child(death_anim)
	
	await get_tree().create_timer(0.5).timeout
	
	player_death.emit()

func _potion_picked_up() -> void:
	_ui_ap.play("pickup")

func _potion_used() -> void:
	_ui_ap.play("use")
