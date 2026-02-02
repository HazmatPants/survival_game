extends Node
class_name PlayerHealth

@onready var LIMBS = {
	"Abdomen": {
		"name": "Abdomen",
		"node": $"../Abdomen"
	},
	"Thorax": {
		"name": "Thorax",
		"node": $"../Abdomen/Thorax"
	},
	"Neck": {
		"name": "Neck",
		"node": $"../Abdomen/Thorax/Neck"
	},
	"Head": {
		"name": "Head",
		"node": $"../Abdomen/Thorax/Neck/Head"
		},
	"LUpperArm": {
		"name": "Left Upper Arm",
		"node": $"../Abdomen/Thorax/LUpperArm"
		},
	"LForearm": {
		"name": "Left Forearm",
		"node": $"../Abdomen/Thorax/LUpperArm/LForearm"
		},
	"LHand": {
		"name": "Left Hand",
		"node": $"../Abdomen/Thorax/LUpperArm/LForearm/LHand"
		},
	"RUpperArm": {
		"name": "Right Upper Arm",
		"node": $"../Abdomen/Thorax/RUpperArm"
		},
	"RForearm": {
		"name": "Right Forearm",
		"node": $"../Abdomen/Thorax/RUpperArm/RForearm"
		},
	"RHand": {
		"name": "Right Hand",
		"node": $"../Abdomen/Thorax/RUpperArm/RForearm/RHand"
		},
	"LThigh": {
		"name": "Left Thigh",
		"node": $"../Abdomen/LThigh"
		},
	"LCrus": {
		"name": "Left Crus",
		"node": $"../Abdomen/LThigh/LCrus"
		},
	"LFoot": {
		"name": "Left Foot",
		"node": $"../Abdomen/LThigh/LCrus/LFoot"
		},
	"RThigh": {
		"name": "Right Thigh",
		"node": $"../Abdomen/RThigh"
		},
	"RCrus": {
		"name": "Right Crus",
		"node": $"../Abdomen/RThigh/RCrus"
		},
	"RFoot": {
		"name": "Right Foot",
		"node": $"../Abdomen/RThigh/RCrus/RFoot"
		},
}

const SFX_HUNGER := [
	preload("res://assets/audio/sfx/player/stomach1.wav"),
	preload("res://assets/audio/sfx/player/stomach2.wav"),
	preload("res://assets/audio/sfx/player/stomach3.wav")
]

const SFX_VOMIT := [
	preload("res://assets/audio/sfx/player/vomit1.ogg"),
	preload("res://assets/audio/sfx/player/vomit2.ogg")
]

var blood_volume: float = 5.0 # liters
var blood_o2: float = 1.0
var brain_health: float = 1.0
var brain_o2: float = 1.0
var exertion: float = 0.0
var consciousness: float = 1.0
var sickness: float = 0.0
var adrenaline: float = 0.0
var physical_work: float = 0.0
var stamina: float = 1.0
var heart_rate: float = 80.0 # bpm
var max_hr: float = 240
var rest_hr: float = 55
var target_hr: float = 80
var blood_clot_speed: float = 0.01
var blood_regen_rate: float = 0.001
var blood_loss_rate: float = 0.0
var calories: float = randf_range(0.7, 1.0)
var hydration: float = randf_range(0.7, 1.0)
var o2_regen_rate: float = 0.12
var temperature: float = 37.0
var ambient_temperature: float = -1.15
var insulation: float = 1.0
var heart_attack: float = 0.0
var rhabdomyolysis: float = 0.0
var hearing_damage: float = 0.0
const O2_USE_RATE: float = 0.1
const BRAIN_DAMAGE_O2_THRESHOLD: float = 0.75
const CONSC_O2_THRESHOLD: float = 0.8
const CONSC_STAMINA_THRESHOLD: float = 0.05
const UNCONSCIOUS_THRESHOLD: float = 0.05

var moodles := {}

var beat_timer: float = 0.0

const SFX_HEARTBEAT = preload("res://assets/audio/sfx/player/heart_thump.ogg")

signal HeartBeat

var hunger_pain := 0.0
var hunger_pain_timer := 0.0
var next_hunger_pain := randf_range(6.0, 12.0)

var vomit_timer := 0.0
var vomiting := false

var _last_consciousness := 0.0
func _process(delta: float) -> void:
	beat_timer += delta
	var beat_interval = 60.0 / heart_rate
	if beat_timer >= beat_interval:
		HeartBeat.emit()
		if not consciousness <= UNCONSCIOUS_THRESHOLD:
			GLOBAL.playsound(SFX_HEARTBEAT, 0.025)
		beat_timer -= beat_interval

	var total_pain = get_limb_total("pain")
	var max_pain = get_limb_all("pain").values().max()

	target_hr = rest_hr + ((physical_work * 10) + adrenaline) * (max_hr - rest_hr)
	target_hr += (temperature - 37) * 5
	target_hr += total_pain
	target_hr += sickness * 300
	target_hr -= (2.0 - calories) * 10
	target_hr += (2.0 - hydration) * 30
	target_hr += (5 - blood_volume) * 60
	if get_moodle("heart_attack"):
		target_hr += 200
		get_limb("Thorax").pain += 0.05 * delta
		blood_o2 -= 0.01 * delta
	if brain_health < 0.5:
		target_hr += randf_range(-0.5, 2.0)

	target_hr = clampf(target_hr, 0.0, max_hr)
	if blood_o2 < 0.8:
		target_hr += (0.8 - blood_o2) * 60.0
	if stamina < 0.5:
		target_hr += (0.5 - stamina) * 60.0

	heart_rate = lerp(heart_rate, target_hr, 0.0025)

	var blood_fraction = (blood_volume / 5.0)

	if get_limb("Thorax").muscle_health <= 0.0:
		set_moodle("respiratory_arrest")

	if not moodles.has("respiratory_arrest"):
		blood_o2 += (o2_regen_rate * blood_fraction) * delta

	blood_o2 = clampf(blood_o2, 0.0, temperature / 36.5)
	blood_o2 = clampf(blood_o2, 0.0, 37.5 / temperature)

	if temperature < 34:
		consciousness -= 0.1 * delta
		if consciousness < 0.3:
			set_moodle("respiratory_arrest")

	add_work(clampf(temperature - 38, 0.0, INF) / 10000)

	if temperature > 44:
		consciousness -= 0.1 * delta
		if consciousness < 0.3:
			set_moodle("respiratory_arrest")

	calories -= 0.0002 * delta
	calories -= (1.0 - stamina) / 1000 * delta
	calories -= max((37 - temperature) / 10000, 0.0) * delta
	hydration -= 0.00025 * delta
	hydration -= max((temperature - 37) / 10000, 0.0) * delta
	hydration -= (1.0 - stamina) / 800 * delta

	calories = clampf(calories, -INF, 2.5)
	hydration = clampf(hydration, -INF, 2.5)

	if calories < 0.4 or sickness > 0.001:
		hunger_pain_timer += delta

		if hunger_pain_timer >= next_hunger_pain:
			hunger_pain_timer = 0.0
			GLOBAL.playsound(GLOBAL.randsfx(SFX_HUNGER), 1.0)
			next_hunger_pain = randf_range(6.0, 12.0)
			hunger_pain = randf() / 20

	hunger_pain = lerp(hunger_pain, 0.0, 0.2)
	get_limb("Abdomen").pain += hunger_pain

	if sickness > 0.05 or vomiting:
		vomit_timer += delta

	if vomit_timer > 10.0 and not vomiting:
		if randf() > 0.6:
			vomiting = true
		else:
			vomit_timer = 0.0

	$Pain.volume_linear = clampf(total_pain - 0.1, 0.0, 2.0)
	$Pain.pitch_scale = lerpf($Pain.pitch_scale, clampf(1.0 + total_pain, 1.0, 5.0), 0.1)
	$Agony.volume_linear = clampf(ease(total_pain, 4), 0.0, 2.0) * 2
	$Tinnitus.volume_linear = clampf(hearing_damage, 0.0, 2.0)

	if (
		blood_o2 < 0.7 or
		calories < 0.0 or
		hydration < 0.0
	):
		$Dying.volume_linear = lerpf($Dying.volume_linear, 2.0, 0.05)
	else:
		$Dying.volume_linear = lerpf($Dying.volume_linear, 0.0, 0.05)

	hearing_damage -= 0.01 * delta
	hearing_damage = clampf(hearing_damage, 0.0, 100.0)

	set_moodle("hearing_damage", hearing_damage)

	if vomiting:
		$Brownian.volume_linear = lerpf($Brownian.volume_linear, (1.0 - consciousness) / 10, 0.05)
		consciousness = lerp(consciousness, 0.1, 0.01)
		if vomit_timer > 14.0:
			vomit_timer = 0.0
			GLOBAL.playsound(GLOBAL.randsfx(SFX_VOMIT))
			if calories > 0.15:
				calories -= 0.15
			else:
				calories = 0.0
			if hydration > 0.2:
				hydration -= 0.2
			else:
				hydration = 0.0
			sickness -= 0.1
			vomiting = false
			var particles: GPUParticles3D = preload("res://scenes/vomit_particles.tscn").instantiate()
			get_tree().current_scene.add_child(particles)
			particles.global_transform = owner.camera.global_transform
			particles.emitting = true
			particles.finished.connect(particles.queue_free)
	else:
		$Brownian.volume_linear = lerpf($Brownian.volume_linear, 1.0 - brain_health, 0.05)
		if brain_health < 0.05:
			$Brownian.volume_linear += (0.05 - brain_health) * 8
		if consciousness > UNCONSCIOUS_THRESHOLD:
			$Brownian.volume_linear /= 10

	if hydration < 0.0:
		blood_o2 = clampf(blood_o2, 0.0, 1.0 - abs(hydration))
		if get_limb("Thorax").pain < 0.5:
			get_limb("Thorax").pain = lerp(get_limb("Thorax").pain, 0.3, 0.001)

	if rhabdomyolysis > 0.0:
		set_moodle("rhabdomyolysis", rhabdomyolysis)

	adrenaline += max_pain / 100 * delta
 
	blood_o2 -= (O2_USE_RATE * (1.0 + physical_work)) * delta
	blood_o2 = clampf(blood_o2, 0.0, blood_volume / 5.0)
 
	brain_o2 += o2_regen_rate * delta

	brain_o2 = clampf(brain_o2, 0.0, min(blood_o2, 1.0))

	blood_loss_rate = get_limb_total("bleeding_rate")

	blood_volume += (blood_regen_rate * calories) * delta

	blood_volume -= blood_loss_rate * delta
	blood_volume = clampf(blood_volume, 0.0, 5.0)

	temperature += physical_work * delta
	temperature += (max_pain / 10) * delta
	temperature += sickness / 100

	physical_work = lerp(physical_work, 0.0, 0.015)
	physical_work = clampf(physical_work, 0.0, 0.2)

	if calories < 0.0:
		blood_o2 -= abs(calories / 40) * delta
		add_work(abs(calories / 200))

	stamina -= physical_work / 30

	if stamina < CONSC_STAMINA_THRESHOLD:
		consciousness -= 0.2 * delta

	if stamina > stamina - sickness:
		stamina = lerpf(stamina, 1.0 - sickness, 0.03)

	if calories < 0.9:
		set_moodle("hunger", 1.0 - calories)

	if get_limb("Abdomen").pain < sickness:
		get_limb("Abdomen").pain = lerp(get_limb("Abdomen").pain, sickness, 0.005)

	if calories < 0.5:
		if get_limb("Abdomen").pain < 0.1:
			get_limb("Abdomen").pain = lerp(get_limb("Abdomen").pain, 0.1, 0.005)

	if hydration < 0.9:
		set_moodle("thirst", 1.0 - hydration)

	if hydration < 0.5:
		if get_limb("Thorax").pain < 0.2:
			get_limb("Thorax").pain = lerp(get_limb("Thorax").pain, 0.1, 0.0005)

	if temperature < 37.0:
		set_moodle("cold", 1.0 - (temperature / 37))

	if temperature > 37.0:
		set_moodle("hot", (temperature - 37) / 42)

	if stamina < 0.3:
		exertion += 1.0 * delta

	sickness -= 0.001 * delta

	sickness = clampf(sickness, 0.0, 1.0)
	consciousness = lerp(consciousness,
		clampf(consciousness, 0.0, ease(1.05 - sickness, 4)),
		0.005
	)

	$Pant.volume_linear = ease(0.9 - stamina, 4)
	$Pant.pitch_scale = 1.0 - (stamina / 5) 

	set_moodle("exertion", 1.0 - stamina)

	if physical_work < 0.01:
		stamina += 0.03 * delta
		exertion = lerp(exertion, 0.0, 0.01)

	temperature = lerp(temperature, temperature + (ambient_temperature * insulation), 0.0005)
	temperature = lerp(temperature, 37.0, 0.0005)

	stamina = clamp(stamina, 0.0001, 1.0)

	adrenaline = lerp(adrenaline, 0.0, 0.0005)

	adrenaline = clamp(adrenaline, 0.0, 1.0)

	consciousness = clampf(consciousness, 0.0, brain_o2)
	if total_pain >= 1.0:
		consciousness -= 0.2 * delta

	consciousness += 0.05 * (1.0 + (adrenaline * 8)) * delta

	if blood_o2 < 0.8:
		heart_attack += 0.01 * delta

	if total_pain > 1.5:
		heart_attack += 0.01 * delta

	if heart_attack > 0.0:
		heart_attack -= 0.005 * delta

	if heart_attack >= 1.0:
		set_moodle("heart_attack")

	if brain_o2 <= CONSC_O2_THRESHOLD:
		consciousness -= (CONSC_O2_THRESHOLD - brain_o2) * delta

	consciousness = clampf(consciousness, 0.0, min(blood_o2, brain_health, get_limb("Head").muscle_health, 1.0))

	if consciousness <= UNCONSCIOUS_THRESHOLD and not _last_consciousness <= UNCONSCIOUS_THRESHOLD:
		Engine.time_scale = 5.0
	if consciousness > UNCONSCIOUS_THRESHOLD and _last_consciousness <= UNCONSCIOUS_THRESHOLD:
		Engine.time_scale = 1.0

	if consciousness <= UNCONSCIOUS_THRESHOLD:
		stamina += 0.1 * delta
		physical_work -= 0.1 * delta

	if brain_o2 < BRAIN_DAMAGE_O2_THRESHOLD:
		brain_health -= (BRAIN_DAMAGE_O2_THRESHOLD - blood_o2) * 0.01 * delta

	blood_clot_speed = lerp(blood_clot_speed, 0.003, 0.025 * delta)

	if blood_volume <= 2.5:
		brain_health -= (2.5 - blood_volume) * 0.00002 * delta

	brain_health = clampf(brain_health, 0.0, 1.0)

	if get_limb("Head").pain < (1.0 - brain_health) / 4:
		get_limb("Head").pain = lerp(get_limb("Head").pain, (1.0 - brain_health) / 4, 0.005)

	owner.viewpunch_target += Vector3(
		randf_range(-max_pain, max_pain),
		randf_range(-max_pain, max_pain),
		randf_range(-max_pain, max_pain)
	) / 10

	var cold = abs(37 - temperature)
	if temperature > 37:
		cold = 0

	owner.viewpunch += Vector3(
		randf_range(-cold, cold),
		randf_range(-cold, cold),
		randf_range(-cold, cold)
	) / 2000

	owner.viewpunch_target += Vector3(
		randf_range(-0.001, 0.001),
		randf_range(-0.001, 0.001),
		randf_range(-0.001, 0.001)
	)

	_brain_damage(delta)

	if brain_health <= 0.0 and not owner.dead:
		owner.die()

	_last_consciousness = consciousness

const SFX_BRAIN_DAMAGE_AMB := [
	preload("res://assets/audio/bgs/brain_damage_amb_1.ogg"),
	preload("res://assets/audio/bgs/brain_damage_amb_2.ogg"),
	preload("res://assets/audio/bgs/brain_damage_amb_3.ogg"),
	preload("res://assets/audio/bgs/brain_damage_amb_4.ogg"),
	preload("res://assets/audio/bgs/brain_damage_amb_5.ogg"),
	preload("res://assets/audio/bgs/ring.ogg"),
]

var sound_timer := 0.0
var next_sound_time := randf_range(10.0, 32.0)
var photopsia_timer := 0.0
var next_photopsia_time := randf_range(2.0, 8.0)
var lobotomy_timer := 0.0
var next_lobotomy_time := randf_range(90.0, 200.0)
func _brain_damage(delta: float) -> void:
	if consciousness <= UNCONSCIOUS_THRESHOLD: return
	if brain_health <= 0.6:
		lobotomy_timer += delta
		if lobotomy_timer > next_lobotomy_time:
			GLOBAL.playsound(preload("res://assets/audio/bgs/lobotomy_buildup.wav"),
				randf(),
				0.0,
				"Brain Damage"
			).finished.connect(_lobotomy)
			lobotomy_timer = 0.0
			next_lobotomy_time = randf_range(60.0, 200.0)
			owner.hud.blur_offset += randf() * 10
	if brain_health <= 0.7:
		sound_timer += delta
		if sound_timer > next_sound_time:
			GLOBAL.playsound(GLOBAL.randsfx(SFX_BRAIN_DAMAGE_AMB), randf(), 0.0, "Brain Damage")
			sound_timer = 0.0
			next_sound_time = randf_range(5.0, 16.0)
	if brain_health <= 0.8:
		photopsia_timer += delta
		if photopsia_timer > next_photopsia_time:
			if randf() > 0.5:
				GLOBAL.playsound(preload("res://assets/audio/bgs/ring.ogg"),
					randf(),
					0.0,
					"Brain Damage"
				)
			photopsia_timer = 0.0
			next_photopsia_time = randf_range(5.0, 16.0)
			owner.hud.blur_offset += randf() * 2
			var light = preload("res://scenes/photopsia_light.tscn").instantiate()
			get_tree().current_scene.add_child(light)
			light.global_position = owner.global_position + Vector3(
				randf_range(-5, 5),
				randf_range(-5, 5),
				randf_range(-5, 5)
			)

func _lobotomy():
	GLOBAL.playsound(
		preload("res://assets/audio/bgs/lobotomy.wav"),
		randf(),
		0.0,
		"Brain Damage"
	)
	owner.hud.blur_offset += randf() * 10
	owner.hud.afterimage(0.8, 5.0, 1.0, 50.0)
	get_limb("Head").pain = 1.0

func get_limb_total(value: String) -> float:
	var total: float = 0.0
	for limb in LIMBS.keys():
		total += get_limb(limb).get(value)
	return total

func get_limb_all(value: String) -> Dictionary:
	var total: Dictionary = {}
	for limb in LIMBS.keys():
		total[limb] = get_limb(limb).get(value)
	return total

func get_limb(limb: String) -> Node3D:
	return LIMBS[limb]["node"]

func get_all_limbs() -> Array:
	var limbs := []
	for limb in LIMBS.values():
		limbs.append(limb["node"])
	return limbs

func add_work(amount: float):
	physical_work += amount * (1.0 + exertion)
	physical_work = clampf(physical_work, 0.0, 0.2)

func set_moodle(moodle_name: String, intensity: float=1.0) -> void:
	moodles[moodle_name] = {"intensity": intensity}

func get_moodle(moodle_name: String) -> float:
	if moodles.has(moodle_name):
		return moodles[moodle_name]["intensity"]
	return 0.0
