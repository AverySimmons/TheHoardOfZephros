class_name Treasure
extends Area2D

signal collected()

func _ready() -> void:
	area_entered.connect(_collect)

func _collect(_area: Area2D) -> void:
	collected.emit()
	$AnimationPlayer.play("open")
	await $AnimationPlayer.animation_finished
	queue_free()
