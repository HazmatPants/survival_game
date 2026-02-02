extends Camera3D

var target_fov := 80.0

func _process(_delta: float) -> void:
	fov = lerp(fov, target_fov, 0.2)
