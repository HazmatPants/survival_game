extends CharacterBody3D

@onready var camera := $Camera3D
@onready var foot_ray := $FootRay
@onready var health: PlayerHealth = $Health
@onready var hud := $HUD
@onready var anim := $AnimationPlayer
@onready var front_ray: RayCast3D = $Abdomen/Thorax/Neck/Head/FrontRay

@export var mouse_sensitivity: float = 0.004
@export var gravity: float = -10.0
@export var jump_force: float = 5.0
@export var walk_speed: float = 0.8
@export var sprint_speed: float = 1.4
@export var viewbob_frequency: float = 6.0
@export var viewbob_amplitude: float = 0.01

var mouse_delta := Vector2.ZERO
var look_angle := Vector2.ZERO
var viewpunch_target := Vector3.ZERO
var viewpunch := Vector3.ZERO
var viewbob_time := 0.0
var viewbob_width := 2.0
var viewbob_height := 1.5
var shock := Vector3.ZERO

@onready var inventory: Inventory = $Inventory

var dead := false
var can_move := true
var sprinting := false
var is_moving: bool = false
var falling_velocity: float = 0.0

const SFX_FOOTSTEP = {
	"grass": {
		"walk": [
			preload("res://assets/audio/sfx/player/footsteps/grass/walk/grass_walk1.ogg"),
			preload("res://assets/audio/sfx/player/footsteps/grass/walk/grass_walk2.ogg"),
			preload("res://assets/audio/sfx/player/footsteps/grass/walk/grass_walk3.ogg"),
			preload("res://assets/audio/sfx/player/footsteps/grass/walk/grass_walk4.ogg"),
			preload("res://assets/audio/sfx/player/footsteps/grass/walk/grass_walk5.ogg"),
			preload("res://assets/audio/sfx/player/footsteps/grass/walk/grass_walk6.ogg"),
			preload("res://assets/audio/sfx/player/footsteps/grass/walk/grass_walk7.ogg"),
			preload("res://assets/audio/sfx/player/footsteps/grass/walk/grass_walk8.ogg"),
			preload("res://assets/audio/sfx/player/footsteps/grass/walk/grass_walk9.ogg"),
			preload("res://assets/audio/sfx/player/footsteps/grass/walk/grass_walk10.ogg")
		],
		"run": [
			preload("res://assets/audio/sfx/player/footsteps/grass/run/grass_run1.ogg"),
			preload("res://assets/audio/sfx/player/footsteps/grass/run/grass_run2.ogg"),
			preload("res://assets/audio/sfx/player/footsteps/grass/run/grass_run3.ogg"),
			preload("res://assets/audio/sfx/player/footsteps/grass/run/grass_run4.ogg")
		]
	}
}

signal foot_stepped

var last_tap_time := {}
const DOUBLE_TAP_TIME := 0.25

func _input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_E:
			var key = event.keycode
			var now := Time.get_ticks_msec() / 1000.0

			if last_tap_time.has(key) and now - last_tap_time[key] <= DOUBLE_TAP_TIME:
				inventory.swap_hands()
				last_tap_time.erase(key)
			else:
				last_tap_time[key] = now

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_delta = event.relative

const SFX_FRACTURE := [
	preload("res://assets/audio/sfx/player/fracture1.ogg"),
	preload("res://assets/audio/sfx/player/fracture2.ogg"),
	preload("res://assets/audio/sfx/player/fracture3.ogg")
]

var was_on_floor: bool = false
func _physics_process(delta: float) -> void:
	var input_vector := Vector3.ZERO

	var forward = -transform.basis.z.normalized()
	var right = transform.basis.x.normalized()

	if Input.is_action_pressed("move_forward"):
		input_vector += forward
	if Input.is_action_pressed("move_left"):
		input_vector -= right
	if Input.is_action_pressed("move_backward"):
		input_vector -= forward
	if Input.is_action_pressed("move_right"):
		input_vector += right

	velocity.y += gravity * delta

	if not is_on_floor():
		falling_velocity = abs(velocity.y)

	if falling_velocity > 5 and not is_on_floor():
		viewpunch_target += Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		) * 0.1

	look_angle.x -= mouse_delta.y * mouse_sensitivity
	look_angle.x = clampf(look_angle.x, deg_to_rad(-85), deg_to_rad(85))
	look_angle.y -= mouse_delta.x * mouse_sensitivity

	rotation.y = lerp_angle(rotation.y, look_angle.y, 0.2)
	var camera_angle := Vector3.ZERO
	camera_angle.x += look_angle.x
	camera_angle += viewpunch
	if health.consciousness > health.UNCONSCIOUS_THRESHOLD:
		camera.rotation.x = lerp_angle(camera.rotation.x, camera_angle.x, 0.2)
		camera.rotation.y = camera_angle.y
		camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))
		camera.rotation.z = camera_angle.z

	viewpunch += Vector3(
		randf_range(-shock.x, shock.x),
		randf_range(-shock.y, shock.y),
		randf_range(-shock.z, shock.z)
	)

	shock = shock.lerp(Vector3.ZERO, 0.05)

	viewpunch = viewpunch.lerp(viewpunch_target, 0.1)
	viewpunch_target = viewpunch_target.lerp(Vector3.ZERO, 0.1 * health.consciousness)

	viewbob_time += (delta * viewbob_frequency) * (velocity.length() / 4)

	var cam_pos = get_limb("Head").global_position
	cam_pos += camera.global_transform.basis.y / 5
	cam_pos -= camera.global_transform.basis.z / 5

	camera.global_position = lerp(camera.global_position, cam_pos, 0.1)

	if input_vector != Vector3.ZERO and not GLOBAL.is_console_open and is_on_floor():
		camera.position += Vector3(
			sin(viewbob_time) * viewbob_width,
			sin(viewbob_time * 2.0) * viewbob_height,
			0.0
		) * 0.01

	viewpunch_target.z -= velocity.dot(camera.global_basis.x) / 1000
	viewpunch_target.z -= mouse_delta.x / 2000

	if Input.is_action_just_pressed("jump") and not GLOBAL.is_console_open:
		if is_on_floor():
			velocity.y += jump_force
			viewpunch_target += Vector3(0.1, 0.0, 0.0)
			health.add_work(0.015)

	var neck = get_limb("Neck")
	if neck.fracture_amount > 0.0:
		neck.pain += (mouse_delta.length() * mouse_sensitivity) * neck.fracture_amount

	mouse_delta = Vector2.ZERO

	var move_mult := ease(health.stamina, 0.2)
	move_mult *= health.temperature / 37
	var speed = walk_speed
	var walking = Input.is_action_pressed("walk")
	sprinting = Input.is_action_pressed("sprint")
	viewbob_width = 2.0
	viewbob_height = 1.0
	if sprinting and not walking:
		viewbob_width = 1.0
		viewbob_height = 2.0
		speed = sprint_speed
	elif walking:
		viewbob_width = 1.0
		speed /= 2
	speed *= move_mult

	if input_vector != Vector3.ZERO and not GLOBAL.is_console_open and can_move:
		anim.play("walk")
		anim.speed_scale = (velocity.length() / 4) * move_mult
		if is_on_floor():
			if not walking:
				health.add_work(0.0001)
			if sprinting and not walking:
				health.add_work(0.00025)
			velocity += input_vector.normalized() * speed
	else:
		anim.play("RESET")
		viewbob_time = lerp(viewbob_time, 0.0, 0.2)

	var step_surface = get_footstep_material()

	var horizontal_velocity = Vector3(velocity.x, 0.0, velocity.z)

	if is_on_floor():
		horizontal_velocity = horizontal_velocity.lerp(Vector3.ZERO, 0.15)

	if is_on_floor() and not was_on_floor: # land
		var step_pos = get_limb("LFoot").position
		step_pos.x = 0.0
		step_pos = to_global(step_pos)
		var type = "walk"
		if sprinting:
			type = "run"
		GLOBAL.playsound3d(GLOBAL.randsfx(SFX_FOOTSTEP[step_surface][type]), step_pos, 0.1)

		viewpunch_target += Vector3(-0.1, 0.0, 0.0)

		print("landed with velocity: %.1f" % falling_velocity)

		_do_fall_damage(step_pos, falling_velocity)

		falling_velocity = 0.0

	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	var right_hand_pos := Transform3D()
	right_hand_pos.origin = camera.global_position
	right_hand_pos.origin -= camera.global_basis.z
	right_hand_pos.origin += camera.global_basis.x
	right_hand_pos.origin -= camera.global_basis.y / 4
	right_hand_pos.basis = camera.global_basis

	if inventory.right_hand:
		inventory.right_hand.global_transform = inventory.right_hand.global_transform.interpolate_with(right_hand_pos, 0.45)

	var left_hand_pos := Transform3D()
	left_hand_pos.origin = camera.global_position
	left_hand_pos.origin -= camera.global_basis.z
	left_hand_pos.origin -= camera.global_basis.x
	left_hand_pos.origin -= camera.global_basis.y / 4
	left_hand_pos.basis = camera.global_basis

	if inventory.left_hand:
		inventory.left_hand.global_transform = inventory.left_hand.global_transform.interpolate_with(left_hand_pos, 0.45)

	was_on_floor = is_on_floor()

	move_and_slide()

	is_moving = velocity.length() > 0.1

	front_ray.global_transform = camera.global_transform

	if Input.is_action_just_pressed("drop"):
		if inventory.choose_hand():
			inventory.drop()

	if Input.is_action_just_pressed("interact"):
		if front_ray.is_colliding():
			var collider = front_ray.get_collider()
			if collider:
				if collider is Item:
					collider.pickup(self)
				elif collider.has_method(&"interact"):
					collider.interact(self)

	if Input.is_action_just_pressed("use"):
		if inventory.choose_hand():
			inventory.choose_hand().use(self)

func get_limb(limb: String) -> Node3D:
	return health.LIMBS[limb]["node"]

func get_footstep_material() -> String:
	var mat = "grass"
	if foot_ray.is_colliding():
		var collider = foot_ray.get_collider()
		if collider:
			if collider.has_meta("material"):
				mat = collider.get_meta("material")
	return mat

func footstep(side: bool):
	if not is_on_floor(): return
	var step_pos := Vector3(0.0, -0.5, 0.0)
	var step_surface = get_footstep_material()
	if side:
		step_pos.x = 0.5
		viewpunch_target += Vector3(-0.025, 0.0, -0.025)
	else:
		viewpunch_target += Vector3(-0.025, 0.0, 0.025)
		step_pos.x = -0.5
	var type = "walk"
	if sprinting:
		type = "run"
	step_pos = to_global(step_pos)
	GLOBAL.playsound3d(GLOBAL.randsfx(SFX_FOOTSTEP[step_surface][type]), step_pos, 0.1)

	foot_stepped.emit("L" if side else "R")

func die():
	dead = true
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")

func _do_fall_damage(step_pos: Vector3, vel: float):
	var fractured := false

	if vel > 6.0:
		GLOBAL.playsound3d(preload("res://assets/audio/sfx/player/land_medium1.ogg"), step_pos, 0.05)
		viewpunch_target += Vector3(-0.4, 0.0, 0.5)

	if vel > 8.0:
		viewpunch += Vector3(-0.5, 0.0, 0.0)
		viewpunch_target += Vector3(-1.0, 0.0, 0.0)
		GLOBAL.playsound3d(preload("res://assets/audio/sfx/player/land_heavy1.ogg"), step_pos, 0.1)
		for limb in health.get_all_limbs():
			if limb.is_leg:
				limb.muscle_health -= randf_range(0.01, vel / 100)
				limb.pain += randf_range(0.01, vel / 125)

	if vel > 15.0:
		GLOBAL.playsound3d(
			preload("res://assets/audio/sfx/player/land_heavy2.ogg"), 
			step_pos,
			0.1
		)

		health.consciousness -= 0.6
		randomize()
		for limb in health.get_all_limbs():
			if not limb.is_leg: continue
			limb.pain += randf_range(0.3, vel / 15)
			limb.fracture_amount += randf_range(0.3, vel / 15)
			fractured = true
			if randf() > 0.1:
				break

	if vel > 17.0:
		health.consciousness = 0.0
		health.adrenaline = 0.0
		health.brain_health -= randf_range(0.1, vel / 100)
		randomize()
		for limb in health.get_all_limbs():
			limb.pain += randf_range(0.3, vel / 15)
			limb.fracture_amount += randf_range(0.3, vel / 15)
			fractured = true
			if randf() > 0.2:
				break

	if fractured:
		GLOBAL.playsound3d(GLOBAL.randsfx(SFX_FRACTURE), step_pos, 0.1)
