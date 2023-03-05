tool
extends HBoxContainer

export (Array, int) var steps: Array = [] setget set_steps
export var progress: int = 0 setget set_progress
export var color1: Color = Color(1, 1, 1) setget set_color1
export var color2: Color = Color(0.5, 0.5, 0.5) setget set_color1


onready var part1 = $dirstring1
onready var part2 = $dirstring2

func _ready():
	_refresh()

func set_steps(x):
	steps = x
	_refresh()

func set_progress(x):
	progress = x
	_refresh()

func set_color1(x):
	color1 = x
	_refresh()

func set_color2(x):
	color2 = x
	_refresh()

func _refresh():
	var prefix = []
	var suffix = []
	for i in steps.size():
		if i < progress:
			prefix.append(steps[i])
		else:
			suffix.append(steps[i])
	if part1:
		part1.steps = prefix
		part1.modulate = color1
	if part2:
		part2.steps = suffix
		part2.modulate = color2
