extends Area3D
class_name Limb

@export var distance_to_heart: float = 1.0
@export var bleed_rate_mult: float = 1.0

@export var is_leg := false
@export var is_arm := false
@export var is_head := false

var bleeding_rate := 0.0
var fracture_amount := 0.0
var skin_health := 1.0
var muscle_health := 1.0
var pain := 0.0
var lactic_acid := 0.0

var moodles := {}

var health: PlayerHealth

var particles_blood: GPUParticles3D = null

func _ready() -> void:
	particles_blood = preload("res://scenes/blood_particles.tscn").instantiate()
	add_child(particles_blood)

	owner.foot_stepped.connect(_footstep)

func _process(delta: float) -> void:
	health = owner.health
	if not health: return

	bleeding_rate -= 0.00001 * delta

	bleeding_rate = clampf(bleeding_rate, 0.0, INF)

	particles_blood.emitting = bleeding_rate > 0.0
	particles_blood.draw_pass_1.radius = bleeding_rate * 50
	particles_blood.draw_pass_1.height = bleeding_rate * 100

	if muscle_health <= 0.0:
		health.rhabdomyolysis += 0.00001 * delta

	muscle_health -= health.rhabdomyolysis * delta

	if health.calories < 0.0:
		muscle_health -= (0.005 * distance_to_heart) * delta
		pain += 0.005 * delta

	if health.temperature > 44.0:
		muscle_health -= (0.005 * distance_to_heart) * delta
		pain += 0.021 * delta

	pain -= (0.01 + (health.adrenaline / 50)) * delta
	fracture_amount -= (0.0001 * health.calories) * delta

	fracture_amount = clampf(fracture_amount, 0.0, 1.0)

	pain = clampf(pain, fracture_amount / 4, 1.0)

	if health.stamina < 0.3 and is_leg and owner.is_moving:
		lactic_acid += 0.01 * delta
	else:
		lactic_acid -= 0.005 * delta

	lactic_acid = clampf(lactic_acid, 0.0, 1.0)

	if lactic_acid > 0.0:
		pain = lerp(pain, max(pain, lactic_acid), 0.2)

func _footstep(side: String):
	if is_leg and side in name:
		if fracture_amount > 0.01:
			pain += fracture_amount / 10

func add_bleed(amount: float):
	bleeding_rate += amount * bleed_rate_mult
