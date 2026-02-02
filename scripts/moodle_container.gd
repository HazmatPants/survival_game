extends VBoxContainer

var moodle_tscn = preload("res://scenes/moodle.tscn")
var moodles := {}

var _last_moodles := {}
func _process(_delta: float) -> void:
	moodles = GLOBAL.player.health.moodles.duplicate(true)
	if _last_moodles != moodles:
		var children := []
		for child in get_children():
			children.append(child.name)
		for moodle in moodles.keys():
			if children.has(moodle):
				var new_moodle = get_node(moodle)
				new_moodle.name = moodle
				new_moodle.intensity = moodles[moodle]["intensity"]
			else:
				var new_moodle = moodle_tscn.instantiate()
				new_moodle.name = moodle
				new_moodle.intensity = moodles[moodle]["intensity"]
				add_child(new_moodle)

	_last_moodles = moodles.duplicate(true)
