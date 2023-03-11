extends Button

func _ready():
# warning-ignore:return_value_discarded
	connect("pressed", self, "_button_pressed")

func _button_pressed():
	Globals.set_music_on(!pressed)
