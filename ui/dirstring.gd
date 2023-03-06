tool
extends Control

export (Array, int) var steps: Array setget set_steps
export var progress: int = 4 setget set_progress
export var color1: Color = Color(1, 1, 1) setget set_color1
export var color2: Color = Color(0.5, 0.5, 0.5) setget set_color1

func _ready():
	_refresh()

func set_steps(s):
	steps = s
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
	var n = steps.size()
	var children = self.get_children()
	for i in range(children.size()):
		children[i].visible = i < n
		if i < progress:
			children[i].modulate = color1
		else:
			children[i].modulate = color2
		if children[i].visible:
			children[i].text = Dir.arrow(steps[i])
