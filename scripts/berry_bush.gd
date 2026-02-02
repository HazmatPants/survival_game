class_name BerryBush
extends Node3D

@export_enum("Adrenaberry", "Red Berry", "Evil Berry", "Waterberry") var berry_type = 0

@export var grow_time: float = 1000.0

enum BERRY {
	ADRENABERRY,
	RED_BERRY,
	EVIL_BERRY,
	WATERBERRY,
}

var timer1 := grow_time
var timer2 := grow_time
var timer3 := grow_time
func _process(delta: float) -> void:
	if $BerryPos.get_child_count() == 0:
		timer1 += delta
	else:
		$BerryPos.get_child(0).scale = $BerryPos.get_child(0).scale.lerp(
			Vector3.ONE,
			0.1
		)
	if $BerryPos2.get_child_count() == 0:
		timer2 += delta
	else:
		$BerryPos2.get_child(0).scale = $BerryPos2.get_child(0).scale.lerp(
			Vector3.ONE,
			0.1
		)
	if $BerryPos3.get_child_count() == 0:
		timer3 += delta
	else:
		$BerryPos3.get_child(0).scale = $BerryPos3.get_child(0).scale.lerp(
			Vector3.ONE,
			0.1
		)

	if timer1 >= grow_time:
		create_berry($BerryPos)
		timer1 = 0.0
	if timer2 >= grow_time:
		create_berry($BerryPos2)
		timer2 = 0.0
	if timer3 >= grow_time:
		create_berry($BerryPos3)
		timer3 = 0.0

func create_berry(parent: Node):
	var path = ""
	match berry_type:
		BERRY.ADRENABERRY:
			path = "res://scenes/items/adrenaberries.tscn"
		BERRY.RED_BERRY:
			path = "res://scenes/items/berries.tscn"
		BERRY.EVIL_BERRY:
			path = "res://scenes/items/evil_berries.tscn"
		BERRY.WATERBERRY:
			path = "res://scenes/items/waterberries.tscn"
	var berry: RigidBody3D = load(path).instantiate()
	berry.freeze = true
	parent.add_child(berry)
	berry.owner = self
	berry.scale = Vector3.ONE / 100
