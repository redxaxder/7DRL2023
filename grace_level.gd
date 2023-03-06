extends Control

export var current: int setget set_current

onready var _label = $Label

func _ready():
	_refresh()

func set_current(c):
	current = c
	_refresh()

func _refresh():
	if _label:
		_label.text = "{0}".format([current])

