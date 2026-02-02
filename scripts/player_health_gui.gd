extends Control

var health: Node

var update_timer: float = 0.0

func _process(delta: float) -> void:
	health = owner.health
	if not health: return
	if not health.HeartBeat.is_connected(_heartbeat):
		health.HeartBeat.connect(_heartbeat)
	if not owner.is_menu_open: return

	update_timer += delta

	owner.set_tooltip(get_element("Consciousness"), "Consciousness %")
	owner.set_tooltip(get_element("Brain/VBoxContainer/HBoxContainer/Label"), "Brain Integrity %")
	owner.set_tooltip(get_element("Brain/VBoxContainer/HBoxContainer/O2Label"), "Brain Oxygen %")
	owner.set_tooltip(get_element("Pain"), "Total Pain %")
	owner.set_tooltip(get_element("Blood/VBoxContainer/HBoxContainer/Label"), "Blood Volume %")
	owner.set_tooltip(get_element("Blood/VBoxContainer/HBoxContainer/O2Label"), "Blood Oxygen %")
	owner.set_tooltip(get_element("Sustenance/Calories"), "Calories")
	owner.set_tooltip(get_element("Sustenance/Hydration"), "Hydration")

	owner.set_tooltip(get_element("Work/Stamina"), "Stamina")
	owner.set_tooltip(get_element("Work/Work"), "Physical Work")
	owner.set_tooltip(get_element("Temperature"), "Core Temperature (°C)")

	owner.set_tooltip(%Heart, "%.02d BPM" % health.heart_rate)

	for child in $Body.get_children():
		var desc := ""

		desc += "Pain: %.1f%%\n" % [health.get_limb(child.name).pain * 100]
		desc += "Skin: %.1f%%\n" % [health.get_limb(child.name).skin_health * 100]
		desc += "Musc: %.1f%%\n" % [health.get_limb(child.name).muscle_health * 100]
		desc += "Bleed: %.2f L/m\n" % [health.get_limb(child.name).bleeding_rate * 60]
		if health.get_limb(child.name).fracture_amount > 0.0:
			desc += "%.1f%% Fractured\n" % [health.get_limb(child.name).fracture_amount * 100]

		if child.name == "Thorax":
			if not owner.is_colliding(%Heart):
				owner.set_tooltip(child, health.LIMBS[child.name]["name"], desc)
		else:
			owner.set_tooltip(child, health.LIMBS[child.name]["name"], desc)

	if not update_timer > 0.1: return
	update_timer = 0.0

	get_element("Brain/VBoxContainer/Bar").value = health.brain_health
	get_element("Brain/VBoxContainer/HBoxContainer/Label").text = "%.1f%%" % [health.brain_health * 100]
	get_element("Brain/VBoxContainer/HBoxContainer/O2Label").text = "%.1f%%" % [health.brain_o2 * 100]

	get_element("Consciousness/VBoxContainer/Bar").value = health.consciousness
	get_element("Consciousness/VBoxContainer/Label").text = "%.1f%%" % [health.consciousness * 100]
	get_element("Pain/Label").text = "%.1f%%" % [health.get_limb_total("pain") * 100]

	get_element("Blood/VBoxContainer/Bar").value = health.blood_volume
	get_element("Blood/VBoxContainer/HBoxContainer/Label").text = "%.1f%%" % [(health.blood_volume / 5.0) * 100]
	get_element("Blood/VBoxContainer/HBoxContainer/O2Label").text = "%.1f%%" % [health.blood_o2 * 100]

	var cal_bar = get_element("Sustenance/Calories/CenterContainer/Bar")
	cal_bar.value = lerp(cal_bar.value, health.calories, 0.2)
	get_element("Sustenance/Calories/Label").text = "%d" % roundf(health.calories * 100)
	var hydr_bar = get_element("Sustenance/Hydration/CenterContainer/Bar")
	hydr_bar.value = lerp(hydr_bar.value, health.hydration, 0.2)
	get_element("Sustenance/Hydration/Label").text = "%d" % roundf(health.hydration * 100)

	get_element("Work/Stamina/CenterContainer/Bar").value = health.stamina
	get_element("Work/Stamina/Label").text = "%.0f%%" % (health.stamina * 100)
	get_element("Work/Work/CenterContainer/Bar").value = health.physical_work * 10
	get_element("Work/Work/Label").text = "%.0f" % (health.physical_work * 1000)

	get_element("Work/Stamina/CenterContainer/Bar").texture_under.gradient.set_color(0, Color(0.157, 0.157, 0.157).lerp(Color.RED, health.exertion / 2))

	get_element("Temperature/TextureRect/ColorRect").scale.y = lerp(0.0, 1.0, health.temperature / 40)
	get_element("Temperature/Label").text = "%.1f°C" % health.temperature

	for limb: Panel in $Body.get_children():
		var stylebox: StyleBoxFlat = limb.get_theme_stylebox("panel").duplicate(true)
		var fill_color := Color.BLACK
		stylebox.bg_color = Color.RED.lerp(fill_color, health.get_limb(limb.name).muscle_health)
		var border_color := Color.WHITE

		stylebox.border_color = Color.RED.lerp(border_color, health.get_limb(limb.name).skin_health)
		limb.add_theme_stylebox_override("panel", stylebox)

	%Heart.get_theme_stylebox("panel").skew = %Heart.get_theme_stylebox("panel").skew.lerp(Vector2.ZERO, 0.2)
	%Heart.scale = %Heart.scale.lerp(Vector2.ONE, 0.5)

func get_element(element: NodePath) -> Control:
	return $HealthStatus/VBoxContainer.get_node(element)

func _heartbeat():
	if not owner.is_menu_open: return
	if owner.tabs.current_tab != 1: return
	GLOBAL.playsound(preload("res://assets/audio/sfx/player/heart_gui.wav"), 0.1, 0.0, "Master", randf_range(0.99, 1.01))
	%Heart.scale = Vector2(1.2, 1.2)
	%Heart.get_theme_stylebox("panel").skew = Vector2(0, randf_range(-0.25, 0.25))
