tool
extends Control

var dance: Dance setget set_dance
onready var _string = $dirstring

func _ready():
	_refresh()

func set_dance(x: Dance):
	dance = x
	_refresh()

func _refresh():
	if !_string: return
	_string.visible = dance != null
	if dance:
		_string.steps = Array(dance.steps)
		_string.progress = dance.progress()

func step(dir: int):
	if dance:
		var _matched = dance.transition(dir)
		if _string:
			_string.progress = dance.progress()
