extends Control

@onready var title = $Panel/VBoxContainer/Title
@onready var description = $Panel/VBoxContainer/Description

var titleText := ""
var descText := ""

var active_this_frame := false

func _ready() -> void:
	modulate.a = 0.0
	$Panel/VBoxContainer/Title.size_flags_horizontal = Control.SIZE_EXPAND
	$Panel/VBoxContainer/Description.size_flags_horizontal = Control.SIZE_EXPAND

func _process(_delta: float) -> void:
	$ReferenceRect.position = get_global_mouse_position()
	var stylebox: StyleBoxFlat = $Panel.get_theme_stylebox("panel").duplicate()
	if get_viewport_rect().encloses($ReferenceRect.get_global_rect()): # move to right
		position = lerp(position, get_global_mouse_position() + Vector2(16, 0), 0.1)
		$ReferenceRect.size = Vector2($Panel.size.x, 10)
		stylebox.corner_radius_top_left = 0
		stylebox.corner_radius_top_right = 8
	else: # move to left
		position = lerp(position, get_global_mouse_position() - Vector2($Panel.size.x + 16, 0), 0.1)
		stylebox.corner_radius_top_left = 8
		stylebox.corner_radius_top_right = 0

	$Panel.add_theme_stylebox_override("panel", stylebox)

	if not active_this_frame:
		modulate.a = lerp(modulate.a, 0.0, 0.3)
		return
	active_this_frame = false
	title.text = titleText
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	description.text = descText
	description.custom_minimum_size.x = len(description.text) * 4
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	$Panel/VBoxContainer.reset_size()
	$Panel.custom_minimum_size.x = $Panel/VBoxContainer.size.x
	$Panel.set_size($Panel/VBoxContainer.size)

	modulate.a = lerp(modulate.a, 1.0, 0.25)

func request_tooltip(Title: String, Desc: String=""):
	titleText = Title
	if not Desc == "":
		descText = Desc
		$Panel/VBoxContainer/Separator.visible = true
		description.visible = true
	else:
		$Panel/VBoxContainer/Separator.visible = false
		description.visible = false
	active_this_frame = true
