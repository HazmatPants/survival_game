extends Node

var player: CharacterBody3D

var is_console_open: bool = false

var mouse_locks := {}

func _ready() -> void:
	player = get_tree().current_scene.get_node_or_null("Player")
	if player:
		await player.ready
		player.hud.health = player.health

## Play a non-3D sound
func playsound(stream: AudioStream,
	volume_linear: float=1.0,
	from_position: float=0.0,
	bus: String="SFX",
	pitch_scale: float=1.0
) -> AudioStreamPlayer:
	var ap := AudioStreamPlayer.new()
	ap.stream = stream
	ap.bus = bus
	ap.volume_linear = volume_linear
	ap.pitch_scale = pitch_scale
	get_tree().current_scene.add_child(ap)
	ap.play(from_position)
	ap.finished.connect(ap.queue_free)
	return ap

## Play a sound in 3D space at global_position
func playsound3d(
	stream: AudioStream,
	global_position: Vector3,
	volume_linear: float=1.0,
	from_position: float=0.0,
	bus: String="SFX",
	pitch_scale: float=1.0
):
	var ap := AudioStreamPlayer3D.new()
	ap.stream = stream
	ap.bus = bus
	ap.volume_linear = volume_linear
	ap.max_db = volume_linear
	ap.pitch_scale = pitch_scale
	get_tree().current_scene.add_child(ap)
	ap.finished.connect(ap.queue_free)
	ap.global_position = global_position

	var distance := ap.global_position.distance_to(player.global_position)
	var delay := distance / 343.0

	await get_tree().create_timer(delay).timeout
	if ap:
		ap.play(from_position)

func randsfx(sound_list: Array) -> AudioStream:
	return sound_list[randi_range(0, sound_list.size() - 1)]

func _process(_delta: float) -> void:
	if not player: return
	var lowpass: AudioEffectLowPassFilter = AudioServer.get_bus_effect(3, 0)
	lowpass.cutoff_hz = lerp(100, 20500,
		clampf(min(player.health.consciousness, 1.0 - player.health.hearing_damage), 0.0, 1.0)
	)
