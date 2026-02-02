extends Node3D

@onready var ray := $RayCast3D

var is_set := true
var grabbed: Node3D = null

@onready var grab_pos := global_position
var grab_rot := 0.0

var pry_progress := 0.0

const SFX_PRY := [
	preload("res://assets/audio/sfx/hazards/beartrap_pry1.ogg"),
	preload("res://assets/audio/sfx/hazards/beartrap_pry2.ogg"),
	preload("res://assets/audio/sfx/hazards/beartrap_pry3.ogg"),
	preload("res://assets/audio/sfx/hazards/beartrap_pry4.ogg"),
	preload("res://assets/audio/sfx/hazards/beartrap_pry5.ogg")
]

func _process(delta: float) -> void:
	if ray.is_colliding():
		var collider: Node3D = ray.get_collider()
		if collider:
			if is_set:
				GLOBAL.playsound3d(preload("res://assets/audio/sfx/hazards/beartrap.ogg"), 
					global_position,
					15.0
				)
				pry_progress = 0.0
				is_set = false
				grabbed = collider
				grab_pos = global_position
				grab_pos.y = collider.global_position.y
				grab_rot = collider.global_rotation.y

				if grabbed == GLOBAL.player:
					var limbs = grabbed.health.LIMBS.keys()
					for limb: String in limbs:
						if grabbed.get_limb(limb).is_leg:
							var limb_type = limb.substr(1)
							if limb_type == "Crus" or limb_type == "Foot":
								grabbed.get_limb(limb).muscle_health -= randf() / 10
								grabbed.get_limb(limb).skin_health -= randf() / 10
								grabbed.get_limb(limb).pain += 0.2 + (randf() / 10)
								grabbed.get_limb(limb).add_bleed(randf() / 1000)
								if randf() > 0.65:
									grabbed.get_limb(limb).fracture_amount += randf() / 5
					grabbed.health.adrenaline += 0.1
					grabbed.shock += Vector3(
						randf_range(-0.1, 0.1),
						randf_range(-0.1, 0.1),
						randf_range(-0.6, 0.6)
					) 

					grabbed.viewpunch_target += Vector3(0.0, -1.0, 0.0)
					grabbed.viewpunch_target += Vector3(
						randf_range(-1, 1),
						randf_range(-1, 1),
						randf_range(-1, 1)
					)

	if is_set:
		$jaw1.rotation_degrees.z = lerp($jaw1.rotation_degrees.z, 0.0, 0.7)
		$jaw2.rotation_degrees.z = lerp($jaw2.rotation_degrees.z, 0.0, 0.7)
	else:
		$jaw1.rotation_degrees.z = lerp($jaw1.rotation_degrees.z, lerp(120.0, 0.0, clampf(pry_progress, 0.0, 1.0)), 0.7)
		$jaw2.rotation_degrees.z = lerp($jaw2.rotation_degrees.z, lerp(-120.0, 0.0, clampf(pry_progress, 0.0, 1.0)), 0.7)

	if grabbed:
		grabbed.global_position = grab_pos
		if grabbed == GLOBAL.player:
			grabbed.can_move = false
			grabbed.look_angle.y = grab_rot
			grabbed.rotation.y = grab_rot
		if pry_progress >= 0.25:
			if grabbed == GLOBAL.player:
				grabbed.can_move = true
			grabbed = null

	if pry_progress > 0.0 and not is_set:
		if global_position.distance_to(GLOBAL.player.global_position) < 2.0:
			pry_progress -= 0.05 * delta
		else:
			pry_progress = 0.0
			GLOBAL.playsound3d(preload("res://assets/audio/sfx/hazards/beartrap.ogg"), 
				global_position,
				0.5
			)

	if pry_progress >= 1.0:
		pry_progress = 0.0
		is_set = true
		GLOBAL.playsound3d(preload("res://assets/audio/sfx/hazards/beartrap_latch.ogg"), 
			global_position,
			0.5
		)

func interact(_player: Node3D):
	if not is_set:
		if global_position.distance_to(GLOBAL.player.global_position) < 2.0:
			if grabbed:
				pry_progress += 0.015
			else:
				pry_progress += 0.25
			GLOBAL.playsound3d(GLOBAL.randsfx(SFX_PRY),
				global_position,
				0.5,
				0.0,
				"SFX",
				0.75
			)
		GLOBAL.player.viewpunch_target += Vector3(
			randf_range(-1, 1),
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * 0.025
		if grabbed == GLOBAL.player:
			var limbs = grabbed.health.LIMBS.keys()
			for limb: String in limbs:
				if grabbed.get_limb(limb).is_leg:
					if randf() > 0.5: continue
					var limb_type = limb.substr(1)
					if limb_type == "Crus" or limb_type == "Foot":
						grabbed.get_limb(limb).pain += randf() / 100
