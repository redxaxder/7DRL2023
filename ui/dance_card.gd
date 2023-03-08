tool
extends Control

var dance: Dance setget set_dance
onready var _string = $Anchor/PanelContainer/HBoxContainer/dirstring
onready var anchor = $Anchor

var ix: int setget set_ix

#var prev_index: int setget
func _ready():
	anchor.snap()
	_refresh()

func set_ix(x):
	if x > ix:
		kick(Vector2(100 + randf() * 40,0))
	elif x < ix:
		kick(Vector2(-50 - randf() * 20,0))
	ix = x

func kick(v):
	anchor.kick(v)

func snap():
	if anchor:
		anchor.snap()

func set_dance(x: Dance):
	dance = x
	_refresh()

func _refresh():
	if !_string: return
	if dance:
		_string.steps = Array(dance.steps)
		_string.progress = dance.progress()

func step(dir: int):
	if dance:
		var _matched = dance.transition(dir)
		if _string:
			_string.progress = dance.progress()
