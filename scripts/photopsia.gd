extends OmniLight3D

func _ready() -> void:
	light_energy = randf_range(1.0, 10.0)

func _process(_delta: float) -> void:
	light_energy = lerp(light_energy, 0.0, 0.3)
	if light_energy <= 0.0:
		queue_free()
