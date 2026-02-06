extends Control

var menu_open := false
var settings_open := false

func _ready() -> void:
	menu_open = false
	modulate.a = 0.0
	visible = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		menu_open = !menu_open
		get_tree().paused = !get_tree().paused
		GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_tab.ogg"))
		if not menu_open:
			settings_open = false

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

	if settings_open:
		$Settings.scale.y = lerp($Settings.scale.y, 1.0, 0.4)
		for child in %SettingsTabs.get_children():
			child.modulate.a = lerp(child.modulate.a, 1.0, 0.2)
	else:
		$Settings.scale.y = lerp($Settings.scale.y, 0.0, 0.4)
		if $Settings.scale.y < 0.01:
			$Settings.hide()

func _on_resume_button_pressed() -> void:
	if not get_tree().paused: return
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	menu_open = false
	GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_click_down.ogg"))
	release_focus()

func _on_settings_button_pressed() -> void:
	settings_open = true
	GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_click_down.ogg"))
	GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_open.wav"))
	$Settings.visible = true
	%SettingsTabs.current_tab = 0

func _on_button_hover():
	if not menu_open: return
	GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_hover.ogg"))

func _on_tab_hovered(tab: int) -> void:
	if tab == %SettingsTabs.current_tab: return
	GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_hover.ogg"))

func _on_tab_selected(tab: int) -> void:
	%SettingsTabs.get_tab_control(tab).modulate.a = 0.0
	if %SettingsTabs.get_tab_title(tab) == "X":
		GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_click_down.ogg"))
		GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_close.wav"))
		settings_open = false
	else:
		GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_tab.ogg"))

const SFX_VOL_CHANGE := preload("res://assets/audio/sfx/ui/volume_change.ogg")

func _on_master_volume_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(bus_idx, value)
	GLOBAL.playsound(SFX_VOL_CHANGE, 1.0, 0.0, "Master")
	%MasterVolValue.text = "%.0f%%" % round(AudioServer.get_bus_volume_linear(bus_idx) * 100)

func _on_sfx_volume_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_linear(bus_idx, value)
	GLOBAL.playsound(SFX_VOL_CHANGE, 1.0, 0.0, "SFX")
	%SFXVolValue.text = "%.0f%%" % round(AudioServer.get_bus_volume_linear(bus_idx) * 100)
