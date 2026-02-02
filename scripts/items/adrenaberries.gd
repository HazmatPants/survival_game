extends ConsumableItem

func pickup(player: CharacterBody3D):
	if owner is BerryBush:
		reparent(get_tree().current_scene)
	_pickup(player)

func use(player):
	player.health.adrenaline += 0.12
	_use(player)
