extends Control

var timer: float = 0.0

var fade_nodes := []

func _ready() -> void:
	AudioServer.get_bus_effect(3, 0).cutoff_hz = 20500
	Engine.time_scale = 1.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GLOBAL.playsound(preload("res://assets/audio/bgs/death_new.ogg"))
	$Label.modulate.a = 0.0
	$Label.position.y = 0.0

	TimeManager.time_scale = 0

	$VBoxContainer/TODLabel.text = "Time of death: " + TimeManager.get_time_string()
	$VBoxContainer/TODLabel.modulate.a = 0.0

	$VBoxContainer/TimeAliveLabel.text = "Survived for: " + TimeManager.get_time_alive_string()
	$VBoxContainer/TimeAliveLabel.modulate.a = 0.0

func _process(delta: float) -> void:
	timer += delta
	$BG.color = $BG.color.lerp(Color.BLACK, 0.1)
	$Label.modulate.a = lerpf($Label.modulate.a, 1.0, 0.025)
	$Label.position.y = lerpf($Label.position.y, 80, 0.3)
	$Label.position += Vector2(
		randf_range(-10, 10),
		randf_range(-10, 10)
	) * (1.0 - $Label.modulate.a)
	$Label.rotation_degrees += randf_range(-1, 1) * (1.0 - $Label.modulate.a)

	if timer > 3.0:
		for child in $VBoxContainer.get_children():
			fade_nodes.append(child)
			await get_tree().create_timer(0.1).timeout

	for node in fade_nodes:
		node.modulate.a = lerpf(node.modulate.a, 1.0, 0.05)
		await get_tree().process_frame
