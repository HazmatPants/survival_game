extends DirectionalLight3D

func _process(_delta: float) -> void:
	rotation_degrees.x = lerp(0, 360, TimeManager.time / 86400) + 90
