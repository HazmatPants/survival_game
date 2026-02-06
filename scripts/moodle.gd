extends Control

const MOODLE_NAMES := {
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
	"cardiac_arrest": "Cardiac Arrest",
	"lactic_acid": "Lactic Acidosis",
}

const MOODLE_DESCRIPTIONS := {
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
	"cardiac_arrest": "Heart has stopped beating. Death imminent.",
	"lactic_acid": "Limbs hurt from anaerobic respiration.",
}

const MOODLE_ICONS := {
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
	"cardiac_arrest": preload("res://assets/textures/ui/icons/cardiac_arrest.svg"),
	"lactic_acid": preload("res://assets/textures/ui/icons/lactic_acid.svg"),
}

@onready var container = get_parent()

var intensity: float = 0.0

func _ready() -> void:
	$Icon.texture = null
	hide()

func _process(_delta: float) -> void:
	match name:
		"respiratory_arrest":
			$Icon.texture = MOODLE_ICONS[name]
			show()
			GLOBAL.player.hud.set_tooltip(
				$BG,
				MOODLE_NAMES["respiratory_arrest"], 
				MOODLE_DESCRIPTIONS["respiratory_arrest"]
			)
		"hunger":
			$Icon.texture = MOODLE_ICONS[name]
			if intensity < 0.2: hide(); return
			show()
			if intensity < 0.3:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["hunger1"], 
					MOODLE_DESCRIPTIONS["hunger1"]
				)
			elif intensity < 0.6:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["hunger2"],
					MOODLE_DESCRIPTIONS["hunger2"]
				)
			elif intensity < 1.0:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["hunger3"], 
					MOODLE_DESCRIPTIONS["hunger3"]
				)
			else:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["hunger4"], 
					MOODLE_DESCRIPTIONS["hunger4"]
				)
		"thirst":
			$Icon.texture = MOODLE_ICONS[name]
			if intensity < 0.2: hide(); return
			show()
			if intensity < 0.3:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["thirst1"], 
					MOODLE_DESCRIPTIONS["thirst1"]
				)
			elif intensity < 0.6:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["thirst2"],
					MOODLE_DESCRIPTIONS["thirst2"]
				)
			elif intensity < 1.0:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["thirst3"], 
					MOODLE_DESCRIPTIONS["thirst3"]
				)
			else:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["thirst4"], 
					MOODLE_DESCRIPTIONS["thirst4"]
				)
		"hot":
			$Icon.texture = MOODLE_ICONS[name]
			if intensity < 0.01: hide(); return
			show()
			if intensity < 0.05:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["hot1"], 
					MOODLE_DESCRIPTIONS["hot1"]
				)
			elif intensity < 0.1:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["hot2"],
					MOODLE_DESCRIPTIONS["hot2"]
				)
			elif intensity < 0.15:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["hot3"], 
					MOODLE_DESCRIPTIONS["hot3"]
				)
			else:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["hot4"], 
					MOODLE_DESCRIPTIONS["hot4"]
				)
		"cold":
			$Icon.texture = MOODLE_ICONS[name]
			if intensity < 0.005: hide(); return
			show()
			if intensity < 0.02:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["cold1"], 
					MOODLE_DESCRIPTIONS["cold1"]
				)
			elif intensity < 0.06:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["cold2"],
					MOODLE_DESCRIPTIONS["cold2"]
				)
			elif intensity < 0.08:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["cold3"], 
					MOODLE_DESCRIPTIONS["cold3"]
				)
			else:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["cold4"], 
					MOODLE_DESCRIPTIONS["cold4"]
				)
		"exertion":
			$Icon.texture = MOODLE_ICONS[name]
			if intensity < 0.5: hide(); return
			show()
			if intensity < 0.7:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["exertion1"], 
					MOODLE_DESCRIPTIONS["exertion1"]
				)
			elif intensity < 0.97:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["exertion2"],
					MOODLE_DESCRIPTIONS["exertion2"]
				)
			else:
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["exertion3"], 
					MOODLE_DESCRIPTIONS["exertion3"]
				)
		"rhabdomyolysis":
			$Icon.texture = MOODLE_ICONS[name]
			show()
			GLOBAL.player.hud.set_tooltip(
				$BG,
				MOODLE_NAMES["rhabdomyolysis"], 
				MOODLE_DESCRIPTIONS["rhabdomyolysis"]
			)
		"heart_attack":
			$Icon.texture = MOODLE_ICONS[name]
			show()
			GLOBAL.player.hud.set_tooltip(
				$BG,
				MOODLE_NAMES["heart_attack"], 
				MOODLE_DESCRIPTIONS["heart_attack"]
			)
		"cardiac_arrest":
			$Icon.texture = MOODLE_ICONS[name]
			show()
			GLOBAL.player.hud.set_tooltip(
				$BG,
				MOODLE_NAMES["cardiac_arrest"], 
				MOODLE_DESCRIPTIONS["cardiac_arrest"]
			)
		"lactic_acid":
			if intensity < 0.01: return
			$Icon.texture = MOODLE_ICONS[name]
			show()
			GLOBAL.player.hud.set_tooltip(
				$BG,
				MOODLE_NAMES["lactic_acid"], 
				MOODLE_DESCRIPTIONS["lactic_acid"]
			)
		"hearing_damage":
			if intensity < 0.01: hide(); return
			show()
			if intensity < 0.5:
				$Icon.texture = MOODLE_ICONS["hearing_damage1"]
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["hearing_damage1"], 
					MOODLE_DESCRIPTIONS["hearing_damage1"]
				)
			elif intensity < 2.0:
				$Icon.texture = MOODLE_ICONS["hearing_damage1"]
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["hearing_damage2"], 
					MOODLE_DESCRIPTIONS["hearing_damage2"]
				)
			else:
				$Icon.texture = MOODLE_ICONS["hearing_damage2"]
				GLOBAL.player.hud.set_tooltip(
					$BG,
					MOODLE_NAMES["hearing_damage3"], 
					MOODLE_DESCRIPTIONS["hearing_damage3"]
				)
	if intensity <= 0.0:
		queue_free()
