extends Node3D



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == GLOBAL.player:
		GLOBAL.playsound3d(preload("res://assets/audio/sfx/hazards/landmine_detect.wav"), global_position)
		GLOBAL.playsound3d(preload("res://assets/audio/sfx/hazards/landmine_detonate.wav"), global_position)
		await get_tree().create_timer(1.3).timeout

		var explosion = preload("res://scenes/explosion.tscn").instantiate()

		get_tree().current_scene.add_child(explosion)

		queue_free()
