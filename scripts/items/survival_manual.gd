extends Item

var open := false

var sfx_page = preload("res://assets/audio/sfx/items/page_turn.wav")

func _ready() -> void:
	$GUI.hide()

func use(player: CharacterBody3D):
	if not open:
		open = true
		GLOBAL.playsound(sfx_page)
	if open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		player.camera.target_fov = 45.0
		$GUI.show()

func drop(player: CharacterBody3D):
	close(player)
	_drop(player)

func close(player):
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.camera.target_fov = 80.0
	open = false
	$GUI.hide()

func _process(_delta: float) -> void:
	if open:
		if is_held:
			global_position -= global_basis.x / 2.955
			global_position += global_basis.y / 14
		$Hinge.rotation.y = lerp_angle($Hinge.rotation.y, deg_to_rad(180), 0.2)
	else:
		$Hinge.rotation.y = lerp_angle($Hinge.rotation.y, 0.0, 0.2)
