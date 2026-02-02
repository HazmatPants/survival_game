extends CanvasLayer

var health: PlayerHealth
@onready var tabs: TabContainer = $Inventory/TabContainer
@onready var moodles: VBoxContainer = $MoodleContainer
@onready var afterimage_overlay: TextureRect = $Afterimage

var is_menu_open: bool = false
var theme_idx := 0

var blood_arrow_tween: Tween

var _last_pain := 0.0
func _ready() -> void:
	$Blackout/Noise.texture.noise.seed = randi()
	get_window().focus_entered.connect(_window_focus_entered)
	get_window().focus_exited.connect(_window_focus_exited)
	$Tooltip.request_tooltip("this is a very very very very very long title", "description")
	$UIBlur.show()
	$Blur.show()
	$Menu.show()
	$Blackout.show()
	$Pain.show()
	$PainNoise.show()
	$Sharp.show()
	tabs.current_tab = 0
	$Inventory/TabContainer/Health/Body.reset_size()
	$Shock.modulate.a = 0.0

	TimeManager.Tick.connect(_tick)

	blood_arrow_tween = %BloodArrow.create_tween()
	var tween = blood_arrow_tween
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(%BloodArrow, "position:y", 10.0, 1.0)
	tween.tween_property(%BloodArrow, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(false)
	tween.tween_property(%BloodArrow, "position:y", -4.0, 0.0)
	tween.tween_property(%BloodArrow, "modulate:a", 1.0, 0.0)
	tween.set_loops()
	tween.stop()
	%BloodArrow.modulate.a = 0.0

var noise_pos := Vector2.ZERO
var noise_time := 10.0

var blur_offset := 0.0

var pain_sine_time := 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("player_menu") and not GLOBAL.is_console_open:
		is_menu_open = !is_menu_open
		if is_menu_open:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$Inventory.show()
			$Inventory.scale.y = 0.0
			GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_open.wav"))
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_close.wav"))
	tab_keybind("inventory", 0)
	tab_keybind("health", 1)
	tab_keybind("os", 2)
	if not health: return

	if is_menu_open:
		$Inventory.scale.y = lerp($Inventory.scale.y, 1.0, 0.4)
		$Inventory.modulate.a = lerp($Inventory.modulate.a, 1.0, 0.4)
	else:
		$Inventory.scale.y = lerp($Inventory.scale.y, 0.0, 0.4)
		$Inventory.modulate.a = lerp($Inventory.modulate.a, 0.0, 0.4)
		if $Inventory.scale.y < 0.01:
			$Inventory.hide()
	$Inventory/TimeLabel.text = TimeManager.get_time_string()

	for child in tabs.get_children():
		child.modulate.a = lerp(child.modulate.a, 1.0, 0.2)

	$Blackout.modulate.a = lerp($Blackout.modulate.a, (1.0 - (health.consciousness + 0.05)), 0.1)

	noise_time += delta

	if noise_time > 60.0:
		noise_pos = Vector2(
			randf_range(-1920, 0),
			randf_range(-1400, 0),
		)
		noise_time = 0

	$Blackout/Noise.position = $Blackout/Noise.position.lerp(noise_pos, 0.0005)
	$Blackout/Noise.modulate = Color(1.0, health.brain_health, health.brain_health, $Blackout/Noise.modulate.a)
	$Blackout/Noise.modulate.a = lerp(0.5, 0.0, health.brain_health)

	var target_blur = lerp(0.0, 2.0, clampf(1.0 - (health.consciousness) + (health.exertion / 10), 0.0, 1.0)) + blur_offset
	var target_ui_blur = 0.0
	if is_menu_open or get_tree().paused:
		target_ui_blur = 5.0

	var current_blur = $Blur/Blur.material.get_shader_parameter("blur_amount")
	var current_ui_blur = $UIBlur/Blur.material.get_shader_parameter("blur_amount")
	blur_offset = lerp(blur_offset, 0.0, 0.1)

	$Blur/Blur.material.set_shader_parameter("blur_amount", lerp(current_blur, target_blur, 0.1))
	$UIBlur/Blur.material.set_shader_parameter("blur_amount", lerp(current_ui_blur, target_ui_blur, 0.2))
	$Sharp/Sharp.material.set_shader_parameter("strength", lerp(5.0, 0.0, clampf(health.hydration, 0.0, 1.0)))

	pain_sine_time += 0.5

	var pain_sine = 2.0 + sin((PI * pain_sine_time) / 30) * 2.0 / 10.0 * PI

	var pain = health.get_limb_total("pain")

	$Pain.modulate.a = pain
	$Pain.scale = (Vector2.ONE * 3.5) * pain_sine
	$Pain.pivot_offset = $Pain.size / 2
	$PainNoise.pivot_offset = $PainNoise.size / 2
	$PainNoise.modulate.a = pain / 1.5
	$PainNoise.texture.noise.seed = randi()
	$PainNoise.rotation_degrees = randi_range(0, 4) * 90

	if afterimage_overlay.modulate.a > 0.0:
		afterimage_overlay.modulate.a -= 0.025 * delta

	if pain > _last_pain:
		$Shock.modulate.a = pain - _last_pain

	if health.blood_loss_rate > 0.0:
		blood_arrow_tween.play()
		blood_arrow_tween.set_speed_scale(health.blood_loss_rate * 100)
		set_tooltip(%BloodArroControl, "-%.2f L/m" % (health.blood_loss_rate * 60))
	else:
		blood_arrow_tween.stop()

	$Shock.modulate.a -= 0.5 * delta
	$Shock.modulate.a = clampf($Shock.modulate.a, 0.0, 1.0)

	_last_pain = pain

func _on_tab_hovered(tab: int) -> void:
	if tab == tabs.current_tab: return
	GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_hover.ogg"))

func switch_to_tab(tab: int) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	tabs.get_current_tab_control().modulate.a = 0.0
	tabs.current_tab = tab
	match tabs.current_tab:
		0:
			GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_tab_inventory.ogg"))
		1:
			GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_tab_health.ogg"))
		2:
			GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_tab_os.ogg"))
		_:
			GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_tab.ogg"))

func tab_keybind(action: String, tab_idx: int):
	if Input.is_action_just_pressed(action) and not GLOBAL.is_console_open:
		if is_menu_open:
			if tabs.current_tab == tab_idx:
				is_menu_open = false
				GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_close.wav"))
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				switch_to_tab(tab_idx)
		else:
			$Inventory.show()
			$Inventory.scale.y = 0.0
			is_menu_open = true
			GLOBAL.playsound(preload("res://assets/audio/sfx/ui/ui_open.wav"), 0.3)
			switch_to_tab(tab_idx)

func set_tooltip(node: Control, title: String, description: String=""):
	if is_colliding(node):
		$Tooltip.request_tooltip(title, description)

func is_colliding(node: Control) -> bool:
	return node.get_global_rect().has_point(get_viewport().get_mouse_position()) and node.is_visible_in_tree()

func _window_focus_entered():
	pass

func _window_focus_exited():
	pass

func afterimage(alpha=1.0, b=5.0, c=1.0, s=1.0):
	var image = get_viewport().get_texture().get_image()
	image.adjust_bcs(b, c, s)
	afterimage_overlay.texture = ImageTexture.create_from_image(image)
	afterimage_overlay.modulate.a = alpha

func _tick():
	if is_menu_open:
		GLOBAL.playsound(preload("res://assets/audio/sfx/ui/tick.wav"))
