extends Control

var menu_open := false

func _ready() -> void:
	menu_open = false
	modulate.a = 0.0

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		menu_open = !menu_open
		get_tree().paused = !get_tree().paused
		GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_tab.ogg"))

		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if menu_open:
		modulate.a = lerp(modulate.a, 1.0, 0.2)
		$Label.visible_ratio += 0.1
	else:
		modulate.a = lerp(modulate.a, 0.0, 0.2)
		$Label.visible_ratio -= 0.1

func _on_resume_button_pressed() -> void:
	if not get_tree().paused: return
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	menu_open = false
	GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_click_down.ogg"))
	release_focus()

func _on_button_hover():
	GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_hover.ogg"))
