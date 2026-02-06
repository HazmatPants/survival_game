class_name Item
extends RigidBody3D

@onready var collision_shape := $CollisionShape3D

@export var display_name: String = ""
@export var id_name: String = ""

var is_held := false

func pickup(player: CharacterBody3D):
	_pickup(player)

func _pickup(player: CharacterBody3D):
	if player.inventory.hands_full(): return
	freeze = false
	player.inventory.pickup(self)
	is_held = true
	gravity_scale = 0.0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	collision_shape.disabled = true

func drop(player: CharacterBody3D):
	_drop(player)

func _drop(_player: CharacterBody3D):
	is_held = false
	gravity_scale = 1.0
	collision_shape.disabled = false

func use(_player: CharacterBody3D): pass
