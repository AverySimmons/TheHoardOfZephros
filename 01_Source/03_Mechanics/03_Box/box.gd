class_name Box
extends CharacterBody2D

@export var weight: float = 10.
@export var push_speed: float = 140.

@onready var area_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var pawn_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	area_shape.shape.size = pawn_shape.shape.size + Vector2.ONE * 10.

func push(dir: float, seen_set: Dictionary):
	seen_set[self] = true
	velocity.x = dir * push_speed
	for box in $Area2D.get_overlapping_bodies():
		if not box in seen_set:
			var push_dir = Vector2(dir, -1).normalized()
			var box_dir = global_position.direction_to(box.global_position)
			
			if push_dir.dot(box_dir) > 0:
				
				if abs(box_dir.y) < 0.6:
					box.push(dir, seen_set)
				else:
					box.push(0.01 * dir, seen_set)

func get_weight(seen: Dictionary) -> float:
	
	var total_weight = 0.;
	seen[self] = true
	
	for n in $Area2D.get_overlapping_bodies():
		if n not in seen:
			if global_position.direction_to(n.global_position).dot(Vector2.UP) > 0.7:
				
				total_weight += n.get_weight(seen)
	
	return total_weight + weight

func get_chain(seen: Dictionary) -> void:
	seen[self] = true
	
	for n in $Area2D.get_overlapping_bodies():
		if n not in seen:
			if global_position.direction_to(n.global_position).dot(Vector2.UP) > 0.7:
				
				n.get_chain(seen)
	
	return

func _physics_process(delta: float):
	if $Pushed.playing and (velocity.x == 0 or not is_on_floor()):
		$Pushed.stop()
	elif not $Pushed.playing and (velocity.x != 0 and is_on_floor()):
		$Pushed.play()
	
	velocity.y += 1000 * delta
	move_and_slide()
	velocity.x = move_toward(velocity.x, 0, 500 * delta)
