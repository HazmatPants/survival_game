extends Control

var page_idx: int = 0

var texts := [
	"""
	[font_size="40px"]How 2 Not Die[/font_size]
	[font_size="10px"]The Ultimate Survival Manual[/font_size]

	This book contains information on how to survive in the wilderness, and of course, how to not die.

	""",
	"""
	[font_size="40px"]Table of Contents[/font_size]

	[url=2]3 - Health Monitor[/url]
	[url=3]4 - Traps[/url]
	[url=4]5 - Bone Fractures[/url]
	[url=5]6 - Joint Dislocations[/url]

	""",
	"""
	[font_size="40px"]Health Monitor[/font_size]

	You are implanted with an SMBIC, [b]S[/b]tatus [b]M[/b]onitoring [b]B[/b]rain [b]I[/b]nterconnected [b]C[/b]omputer.

	The Health Monitor displays your current health status. It can be opened by pressing [code]H[/code]

	On the left you will see a list of statistics.
	Hover over one to see what it is.
	On the right is a visualization of your limbs.
	Hover over one to see its skin integrity, muscle integrity, and current pain.
	""",
	"""
	[font_size="40px"]Traps[/font_size]

	[font_size="30px"]Bear Traps[/font_size]
	Bear traps are a type of foothold trap. When stepped on, the jaws forcefully close, keeping whatever stepped on it from moving. Some are powerful enough to cause small [url=4]Bone Fractures[/url]

	[font_size="30px"]Landmines[/font_size]
	Landmines are anti-personnel mines, they detect when a person is near, then detonate after a short delay. They are extremely deadly, as they launch hundreds of fragments in all directions, possibly injuring even 20 meters away. Within 5 meters, death is almost guaranteed.
	""",
	"""
	[font_size="40px"]Fractures[/font_size]
	
	Bone fractures are when a bone breaks. Typically caused by falling or any external trauma to the limb.
	
	Fractures can be treated by not using the affected limb, and applying a splint.
	""",
	"""
	[font_size="40px"]Dislocations[/font_size]
	
	Joint dislocations are when a bone is forcefully removed from a joint. Typically caused by falling.
	
	Dislocations are unfortunately not easy to treat. The only way is to push the bone back into the joint, which is extremely painful.
	""",
]

func _ready() -> void:
	%CloseButton.pressed.connect(_close_button_clicked)
	%PrevButton.pressed.connect(_prev_button_clicked)
	%NextButton.pressed.connect(_next_button_clicked)
	%PageText.meta_clicked.connect(_meta_clicked)
	set_text(texts[page_idx])

func _process(_delta: float) -> void:
	if page_idx > 0:
		%PrevButton.modulate.a = lerp(%PrevButton.modulate.a, 1.0, 0.2)
	else:
		%PrevButton.modulate.a = lerp(%PrevButton.modulate.a, 0.0, 0.2)
	if page_idx < texts.size() - 1:
		%NextButton.modulate.a = lerp(%NextButton.modulate.a, 1.0, 0.2)
	else:
		%NextButton.modulate.a = lerp(%NextButton.modulate.a, 0.0, 0.2)

func _close_button_clicked():
	owner.close(GLOBAL.player)
	GLOBAL.playsound(preload("res://assets/audio/sfx/items/book_close.wav"))

func _prev_button_clicked():
	if page_idx > 0:
		page_idx -= 1
		set_text(texts[page_idx])
		GLOBAL.playsound(owner.sfx_page)

func _next_button_clicked():
	if page_idx < texts.size() - 1:
		page_idx += 1
		set_text(texts[page_idx])
		GLOBAL.playsound(owner.sfx_page)

func set_text(text: String):
	%PageText.text = text.dedent()
	%PageNumLabel.text = "%.02d" % [page_idx + 1]

func _meta_clicked(meta):
	page_idx = int(meta)
	set_text(texts[page_idx])
	GLOBAL.playsound(owner.sfx_page)
