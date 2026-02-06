class_name ConsumableItem
extends Item

@export var calories: float = 0.0
@export var hydration: float = 0.0
@export var uses: int = 1

@export var use_sounds: Array[AudioStream] = [
	preload("res://assets/audio/sfx/items/bite1.wav"),
	preload("res://assets/audio/sfx/items/bite2.wav"),
	preload("res://assets/audio/sfx/items/bite3.wav"),
	preload("res://assets/audio/sfx/items/bite4.wav"),
	preload("res://assets/audio/sfx/items/bite5.wav"),
	preload("res://assets/audio/sfx/items/bite6.wav"),
	preload("res://assets/audio/sfx/items/bite7.wav"),
	preload("res://assets/audio/sfx/items/bite8.wav"),
	preload("res://assets/audio/sfx/items/bite9.wav"),
]

func _use(player: CharacterBody3D):
	GLOBAL.playsound(GLOBAL.randsfx(use_sounds), 1.0, 0.0, "Master", randf_range(0.95, 1.05))
	player.health.calories += calories
	player.health.hydration += hydration
	uses -= 1
	if uses < 1:
		drop(player)
		queue_free()

func use(player: CharacterBody3D):
	_use(player)
