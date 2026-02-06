extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D

const SFX_SHRAP_WHIZ := [
	preload("res://assets/audio/sfx/whizby/whiz_near1.wav"),
	preload("res://assets/audio/sfx/whizby/whiz_near2.wav"),
	preload("res://assets/audio/sfx/whizby/whiz_near3.wav"),
	preload("res://assets/audio/sfx/whizby/whiz_near4.wav"),
	preload("res://assets/audio/sfx/whizby/whiz_near5.wav"),
	preload("res://assets/audio/sfx/whizby/whiz_near6.wav"),
	preload("res://assets/audio/sfx/whizby/whiz_near7.wav"),
	preload("res://assets/audio/sfx/whizby/whiz_near8.wav"),
	preload("res://assets/audio/sfx/whizby/whiz_near9.wav"),
	preload("res://assets/audio/sfx/whizby/whiz_near10.wav"),
	preload("res://assets/audio/sfx/whizby/whiz_near11.wav"),
	preload("res://assets/audio/sfx/whizby/whiz_near12.wav"),
	preload("res://assets/audio/sfx/ricochet/richochet1.wav"),
	preload("res://assets/audio/sfx/ricochet/richochet2.wav"),
	preload("res://assets/audio/sfx/ricochet/richochet3.wav"),
	preload("res://assets/audio/sfx/ricochet/richochet4.wav"),
	preload("res://assets/audio/sfx/ricochet/richochet5.wav"),
	preload("res://assets/audio/sfx/ricochet/richochet6.wav"),
	preload("res://assets/audio/sfx/ricochet/richochet7.wav"),
	preload("res://assets/audio/sfx/ricochet/richochet8.wav"),
	preload("res://assets/audio/sfx/ricochet/richochet9.wav"),
	preload("res://assets/audio/sfx/ricochet/richochet10.wav"),
]

const SFX_HIT_FLESH := [
	preload("res://assets/audio/sfx/player/impact/bullet_hit_flesh1.wav"),
	preload("res://assets/audio/sfx/player/impact/bullet_hit_flesh2.wav"),
	preload("res://assets/audio/sfx/player/impact/bullet_hit_flesh3.wav"),
	preload("res://assets/audio/sfx/player/impact/bullet_hit_flesh4.wav"),
	preload("res://assets/audio/sfx/player/impact/bullet_hit_flesh5.wav"),
	preload("res://assets/audio/sfx/player/impact/bullet_hit_flesh6.wav"),
	preload("res://assets/audio/sfx/player/impact/bullet_hit_flesh7.wav"),
	preload("res://assets/audio/sfx/player/impact/bullet_hit_flesh8.wav"),
	preload("res://assets/audio/sfx/player/impact/bullet_hit_flesh9.wav"),
	preload("res://assets/audio/sfx/player/impact/bullet_hit_flesh10.wav"),
	preload("res://assets/audio/sfx/player/impact/bullet_hit_flesh11.wav"),
]

var body := GLOBAL.player

func _ready() -> void:
		GLOBAL.playsound3d(preload("res://assets/audio/sfx/hazards/landmine_explode.wav"), global_position, 20.0, 0.0, "SFX", randf_range(0.98, 1.02))
		particles.reparent(get_tree().current_scene)
		particles.emitting = true
		var light := OmniLight3D.new()
		var distance = global_position.distance_to(body.global_position) * 10
		var hd = clampf(11.0 - (distance / 10), 0.0, INF)
		body.health.hearing_damage += hd
		light.light_energy = 100.0
		light.omni_range = 10.0
		light.light_size = 50.0
		get_tree().current_scene.add_child(light)
		var tween = light.create_tween()
		tween.tween_property(light, "light_energy", 0.0, 0.1)
		light.global_position = global_position

		for i in range(300):
			randomize()
			var to = Vector3(
				randf_range(-50, 50),
				randf_range(0, 50),
				randf_range(-50, 50)
			)
			var query = PhysicsRayQueryParameters3D.create(global_position, 
			to_global(to))
			query.collide_with_bodies = false
			query.collide_with_areas = true

			DebugDraw3D.draw_line(global_position, to, Color.WHITE, 0.01)

			var result := get_world_3d().direct_space_state.intersect_ray(query)

			if result:
				var collider = result["collider"]
				GLOBAL.playsound3d(
					GLOBAL.randsfx(SFX_SHRAP_WHIZ),
					global_position.lerp(to, 0.5),
					2.0
				)
				print("Fragment hit: %s, %s" % [
					collider.owner.name, collider.name
					])
				if collider is Limb:
					body.shock += Vector3.ONE * 0.05
					GLOBAL.playsound(
						preload("res://assets/audio/sfx/player/impact/bullet_hit_flesh_lfe.wav"),
						5.0,
						0.0,
						"Master"
					)
					GLOBAL.playsound3d(
						GLOBAL.randsfx(SFX_HIT_FLESH),
						result["position"],
						5.0,
						0.0,
						"SFX"
					)
					collider.pain += randf_range(0.3, 0.5)
					collider.muscle_health -= randf() / 2
					collider.skin_health -= randf() / 2
					collider.add_bleed(randf() / 50)
					if collider.is_head:
						collider.health.consciousness = 0.0
						collider.health.brain_health -= randf_range(0.6, 1.0)
						GLOBAL.playsound(
							preload("res://assets/audio/bgs/ring.ogg"),
							50.0,
							0.0,
							"Master"
						)

		if distance < 60.0:
			body.health.consciousness = 0.0
			body.health.stamina = 0.0
			body.health.brain_health -= randf() / (distance / 8)
			for limb: Limb in body.health.get_all_limbs():
				limb.pain += randf() / 2
				limb.muscle_health -= randf() / (distance / 20)
				limb.skin_health -= randf() / (distance / 20)
				limb.fracture_amount += randf() / (distance / 10)
				limb.add_bleed(randf() / (distance * 30))
		else:
			if distance < 300.0:
				body.health.consciousness -= 0.5
				body.health.adrenaline += 0.2
				body.shock += Vector3.ONE * 0.15
			if distance < 200.0:
				body.health.stamina -= 0.7
				body.shock += Vector3.ONE * 0.25

		queue_free()
