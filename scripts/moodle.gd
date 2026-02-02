extends Control

const moodle_names := {
	"hunger1": "Peckish",
	"hunger2": "Hungry",
	"hunger3": "Very Hungry",
	"hunger4": "Starving",
	"thirst1": "Thirsty",
	"thirst2": "Dehydrated",
	"thirst3": "Parched",
	"thirst4": "Desiccated",
	"hot1": "Warm",
	"hot2": "Hot",
	"hot3": "Hyperthermia",
	"hot4": "Heatstroke",
	"cold1": "Chilly",
	"cold2": "Cold",
	"cold3": "Hypothermia",
	"cold4": "Freezing to death",
	"respiratory_arrest": "Respiratory Arrest",
	"exertion1": "Exerted",
	"exertion2": "Very Exerted",
	"exertion3": "Incapacitated",
	"rhabdomyolysis": "Rhabdomyolysis",
	"heart_attack": "Heart Attack",
	"hearing_damage1": "Minor Acoustic Trauma",
	"hearing_damage2": "Acoustic Trauma",
	"hearing_damage3": "Deaf",
}

const moodle_descriptions := {
	"hunger1": "Could use a bite to eat.",
	"hunger2": "Tummy rumbling.",
	"hunger3": "Tummy hurts... Need food quickly.",
	"hunger4": "Whole body hurts, it's getting hard to move, need food NOW.",
	"thirst1": "Could use a drink.",
	"thirst2": "Mouth dry, very thirsty.",
	"thirst3": "Chest hurts... Need water quickly.",
	"thirst4": "Body drying out, getting hard to breathe...",
	"hot1": "A little warm.",
	"hot2": "Unpleasantly hot.",
	"hot3": "Too hot...",
	"hot4": "Cells dying from heat...",
	"cold1": "A little cold.",
	"cold2": "Unpleasantly cold. Shivering...",
	"cold3": "Dangerously cold, body slowly shutting down",
	"cold4": "Body quickly shutting down from extreme cold.",
	"respiratory_arrest": "Can't breathe...",
	"exertion1": "Out of breath, take a rest.",
	"exertion2": "Completely out of breath, limbs hurt from exertion",
	"exertion3": "Unable to move due to extreme exertion.",
	"rhabdomyolysis": "Muscles breaking down rapidly from extreme trauma.",
	"heart_attack": "Heart rate increasing rapidly, extreme chest pain.",
	"hearing_damage1": "Ears ringing, but no permanent damage. Hearing frequency range slightly reduced.",
	"hearing_damage2": "Eardrums damaged, hearing frequency range reduced.",
	"hearing_damage3": "Eardrums perforated, your ears are beyond repair. Hearing is impossible.",
}

const moodle_icons := {
	"hunger": preload("res://assets/textures/ui/icons/utensils.svg"),
	"thirst": preload("res://assets/textures/ui/icons/glass.svg"),
	"cold": preload("res://assets/textures/ui/icons/cold.svg"),
	"hot": preload("res://assets/textures/ui/icons/hot.svg"),
	"exertion": preload("res://assets/textures/ui/icons/lungs.svg"),
	"respiratory_arrest": preload("res://assets/textures/ui/icons/lungs_cross.svg"),
	"rhabdomyolysis": preload("res://assets/textures/ui/icons/rhabdomyolysis.png"),
	"heart_attack": preload("res://assets/textures/ui/icons/heart_attack.svg"),
	"hearing_damage1": preload("res://assets/textures/ui/icons/acoustic_trauma.svg"),
	"hearing_damage2": preload("res://assets/textures/ui/icons/deaf.svg"),
}

@onready var container = get_parent()

var intensity: float = 0.0

func _ready() -> void:
	$Icon.texture = null
	hide()

func _process(_delta: float) -> void:
	match name:
		"respiratory_arrest":
			$Icon.texture = moodle_icons[name]
			show()
			GLOBAL.player.hud.set_tooltip(
				$BG,
				moodle_names["respiratory_arrest"], 
				moodle_descriptions["respiratory_arrest"]
			)
		"hunger":
			$Icon.texture = moodle_icons[name]
			if intensity < 0.2: hide(); return
			show()
			if intensity < 0.3:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["hunger1"], 
					moodle_descriptions["hunger1"]
				)
			elif intensity < 0.6:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["hunger2"],
					moodle_descriptions["hunger2"]
				)
			elif intensity < 1.0:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["hunger3"], 
					moodle_descriptions["hunger3"]
				)
			else:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["hunger4"], 
					moodle_descriptions["hunger4"]
				)
		"thirst":
			$Icon.texture = moodle_icons[name]
			if intensity < 0.2: hide(); return
			show()
			if intensity < 0.3:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["thirst1"], 
					moodle_descriptions["thirst1"]
				)
			elif intensity < 0.6:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["thirst2"],
					moodle_descriptions["thirst2"]
				)
			elif intensity < 1.0:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["thirst3"], 
					moodle_descriptions["thirst3"]
				)
			else:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["thirst4"], 
					moodle_descriptions["thirst4"]
				)
		"hot":
			$Icon.texture = moodle_icons[name]
			if intensity < 0.01: hide(); return
			show()
			if intensity < 0.05:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["hot1"], 
					moodle_descriptions["hot1"]
				)
			elif intensity < 0.1:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["hot2"],
					moodle_descriptions["hot2"]
				)
			elif intensity < 0.15:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["hot3"], 
					moodle_descriptions["hot3"]
				)
			else:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["hot4"], 
					moodle_descriptions["hot4"]
				)
		"cold":
			$Icon.texture = moodle_icons[name]
			if intensity < 0.005: hide(); return
			show()
			if intensity < 0.02:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["cold1"], 
					moodle_descriptions["cold1"]
				)
			elif intensity < 0.06:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["cold2"],
					moodle_descriptions["cold2"]
				)
			elif intensity < 0.08:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["cold3"], 
					moodle_descriptions["cold3"]
				)
			else:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["cold4"], 
					moodle_descriptions["cold4"]
				)
		"exertion":
			$Icon.texture = moodle_icons[name]
			if intensity < 0.5: hide(); return
			show()
			if intensity < 0.7:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["exertion1"], 
					moodle_descriptions["exertion1"]
				)
			elif intensity < 0.97:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["exertion2"],
					moodle_descriptions["exertion2"]
				)
			else:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["exertion3"], 
					moodle_descriptions["exertion3"]
				)
		"rhabdomyolysis":
			$Icon.texture = moodle_icons[name]
			show()
			GLOBAL.player.hud.set_tooltip(
				$BG,
				moodle_names["rhabdomyolysis"], 
				moodle_descriptions["rhabdomyolysis"]
			)
		"heart_attack":
			$Icon.texture = moodle_icons[name]
			show()
			GLOBAL.player.hud.set_tooltip(
				$BG,
				moodle_names["heart_attack"], 
				moodle_descriptions["heart_attack"]
			)
		"hearing_damage":
			if intensity < 0.01: hide(); return
			show()
			if intensity < 0.5:
				$Icon.texture = moodle_icons["hearing_damage1"]
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["hearing_damage1"], 
					moodle_descriptions["hearing_damage1"]
				)
			elif intensity < 2.0:
				$Icon.texture = moodle_icons["hearing_damage1"]
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["hearing_damage2"], 
					moodle_descriptions["hearing_damage2"]
				)
			else:
				$Icon.texture = moodle_icons["hearing_damage2"]
				GLOBAL.player.hud.set_tooltip(
					$BG,
					moodle_names["hearing_damage3"], 
					moodle_descriptions["hearing_damage3"]
				)
	if intensity <= 0.0:
		queue_free()
