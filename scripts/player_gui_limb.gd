extends Panel

var base_pos := Vector2.ZERO

var health: Node

func _ready() -> void:
	resized.connect(_reset_size)

func _process(_delta: float) -> void:
	health = owner.health
	if not health: return

	var pain = health.get_limb(name).pain

	set_position(base_pos + Vector2(
		randf_range(-pain, pain),
		randf_range(-pain, pain)
	) * 3)

func _reset_size():
	base_pos = position
