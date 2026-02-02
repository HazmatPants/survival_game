extends Control

func _ready() -> void:
	$VBoxContainer/Label.text = $VBoxContainer/Label.text.replace("<ID>", str(hash(randi_range(1000, 9999))))

func _process(_delta: float) -> void:
	%SurvivalTimeLabel.text = "Time Survived: %s" % TimeManager.get_time_alive_string()
