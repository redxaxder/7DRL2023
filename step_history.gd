tool
extends Control

export (Array, int) var steps: Array setget set_steps

func _ready():
	_refresh()

func set_steps(s):
	steps = s
	_refresh()
	
func _refresh():
	var n = steps.size()
	var children = self.get_children()
	for i in range(children.size()):
		children[i].visible = i < n
		if children[i].visible:
			children[i].text = Dir.arrow(steps[i])
