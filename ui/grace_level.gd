extends Label

export var current: int setget set_current

func _ready():
	_refresh()

func set_current(c):
	current = c
	_refresh()

func _refresh():
#	text = ""
#	for i in range(current):
#		text += "☼"
	text = "{0}".format([current])

