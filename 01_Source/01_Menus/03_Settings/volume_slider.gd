extends HSlider

var master = AudioServer.get_bus_index("Master")

func _ready() -> void:
	value = AudioServer.get_bus_volume_linear(master)
	
	value_changed.connect(_value_changed)

func _value_changed(v: float):
	AudioServer.set_bus_volume_linear(master, v)
