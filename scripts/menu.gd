extends Control

var menu_open := false

func _ready() -> void:
	menu_open = false
	modulate.a = 0.0

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		menu_open = !menu_open
		get_tree().paused = !get_tree().paused

		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if menu_open:
		modulate.a = lerp(modulate.a, 1.0, 0.2)
	else:
		modulate.a = lerp(modulate.a, 0.0, 0.2)

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	menu_open = false
