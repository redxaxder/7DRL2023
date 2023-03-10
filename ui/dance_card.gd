extends Control

var dance: Dance setget set_dance
var gamestate: GameState setget set_gamestate

onready var _string = $Anchor/MarginContainer/HBoxContainer/PanelContainer/dirstring
onready var anchor = $Anchor
onready var highlight = $Anchor/MarginContainer/highlight

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

func set_gamestate(x: GameState):
	gamestate = x
	_refresh()

func _refresh():
	if !_string: return
	if dance:
		_string.steps = Array(dance.steps)
		_string.progress = dance.progress()
	highlight.visible = _string.progress >= 3

func step(dir: int):
	if dance:
		var _matched = dance.transition(dir)
		_refresh()
