extends ConsumableItem

func pickup(player: CharacterBody3D):
	if owner is BerryBush:
		reparent(get_tree().current_scene)
	_pickup(player)
