extends Control

var is_console_open: bool = false

@onready var i: LineEdit = $LineEdit
@onready var o: RichTextLabel = $Panel/Output

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_QUOTELEFT and event.pressed and event.ctrl_pressed:
			is_console_open = !is_console_open
			GLOBAL.is_console_open = is_console_open
			if is_console_open:
				show()
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				i.grab_focus()
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				i.text = i.text.replace("`", "")
				i.release_focus()

func _process(_delta: float) -> void:
	if is_console_open:
		scale.y = lerp(scale.y, 1.0, 0.2)
	else:
		scale.y = lerp(scale.y, 0.0, 0.2)

		if scale.y < 0.01:
			hide()

func printout(text: String="", end: String="\n"):
	o.append_text(text + end)

func _on_text_submitted(new_text: String) -> void:
	i.clear()

	printout(">>> " + new_text)

	var args: Array = new_text.split(" ", false)
	var command = args.pop_front()

	match command:
		"help":
			var help = "moodle <subcommand>\n"
			help += "	getall - returns a list of all moodles\n\n"
			help += "time <subcommand> <value>\n"
			help += "	NOTE: time is a range from 0 to 86400 (24 hours in seconds)\n"
			help += "	scale - set the game timescale to <value>\n"
			help += "		default timescale is 10\n"
			help += "		timescale of 1 would make the game real-time\n"
			help += "	set - set the game time to <value>\n"
			help += "	add - add <value> seconds to the game time\n\n"
			help += "vomit - makes you vomit\n"
			printout(help)
		"moodle":
			if args.size() < 1:
				printout("[color=red]moodle: error: missing subcommand (getall, add)[/color]")
				return
			var subcommand = args.pop_front()
			match subcommand:
				"getall":
					var moodles = GLOBAL.player.health.moodles
					for moodle in moodles:
						printout(moodle)
				"add":
					if args.size() < 1:
						printout("[color=red]moodle: error: missing target moodle[/color]")
						return
					GLOBAL.player.health.moodles[args[0]] = {"intensity": 1.0}
				_:
					printout("[color=red]moodle: error: %s is not a valid subcommand[/color]" % subcommand)
		"time":
			if args.size() < 1:
				printout("[color=red]time: error: missing subcommand (scale, set, add)[/color]")
				return
			var subcommand = args.pop_front()
			match subcommand:
				"scale":
					if not args[0].is_valid_float():
						printout("[color=red]time: error: %s is not a valid float[/color]" % args[0])
						return
					TimeManager.time_scale = args[0].to_float()
					printout("set time scale to " + args[0])
				"set":
					if args[0].is_valid_float():
						TimeManager.time = args[0].to_float()
					else:
						match args[0]:
							"midnight":
								TimeManager.time = 0
							"night":
								TimeManager.time = 10000
							"dawn":
								TimeManager.time = 20000
							"day":
								TimeManager.time = 32000
							"noon":
								TimeManager.time = 43200
							"dusk":
								TimeManager.time = 65000
							_:
								printout("[color=red]time: error: %s is not a valid time constant[/color]" % args[0])
					printout("time is now %.2f" % TimeManager.time)
				"add":
					if not args[0].is_valid_float():
						printout("[color=red]time: error: %s is not a valid float[/color]" % args[0])
						return
					TimeManager.time += args[0].to_float()
					printout("added %.2f time (time is now %.2f)" % [float(args[0]), TimeManager.time])
				_:
					printout("[color=red]time: error: %s is not a valid subcommand[/color]" % subcommand)
		"vomit":
			GLOBAL.player.health.vomiting = true
			GLOBAL.player.health.vomit_timer = 10.0#
		"sethealthvar":
			if args.size() < 1:
				printout("[color=red]sethealthvar: error: missing target value[/color]")
				return
			if args.size() < 2:
				printout("[color=red]sethealthvar: error: missing new value[/color]")
				return
			var stat: Node = GLOBAL.player.health

			var properties = stat.get_property_list()

			var found := false

			for prop in properties:
				print(prop["name"])
				if prop["name"] == args[0]:
					found = true
					break

			if found:
				stat.set(args[0], args[1])
			else:
				printout("[color=red]sethealthvar: error: var %s not found[/color]" % args[0])

		_:
			printout("invalid command")
