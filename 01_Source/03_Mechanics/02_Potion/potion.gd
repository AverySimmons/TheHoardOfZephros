extends Area2D

func pick_up() -> void:
	set_deferred("monitorable", false)
	$PickedUp.play()
	$PickupParticles.emitting = true
	$AnimationPlayer.play("fade")
	await $AnimationPlayer.animation_finished
	queue_free()
