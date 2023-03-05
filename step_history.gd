extends Control

export (Array, int) var steps: Array setget set_steps

onready var label = $Label

func _ready():
	_refresh()

func set_steps(s):
	steps = s
	_refresh()
	
func _refresh():
	if label:
		label.text = Core.steps_to_string(steps)
