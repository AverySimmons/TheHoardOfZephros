extends Area2D

func open() -> void:
	$Closed.visible = false
	$Opened.play()
