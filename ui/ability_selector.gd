tool
extends HBoxContainer

export var selected: int = 0 setget set_selected
export var level: int = 0 setget set_level

onready var highlights = [$MarginContainer3/highlight, $MarginContainer2/highlight, $MarginContainer/highlight]


const costs = [99999,-1,1]

signal selector_click(ability)

func set_selected(x):
	selected = x
	_refresh()

func set_level(x):
	level = x
	_refresh()

func _ready():
	for i in get_children().size():
# warning-ignore:return_value_discarded
		get_child(i).get_child(0).connect("button_down", self, "_on_select", [i])
	_refresh()

func _refresh():
	if !highlights:
		return
	for i in highlights.size():
		highlights[i].visible = i == selected
	for i in get_children().size():
		if i == selected && costs[i] <= level:
			get_child(i).modulate = Color(1,1,1)
		else:
			get_child(i).modulate = Color(0.6,0.6,0.6)

func _on_select(ix: int):
	emit_signal("selector_click", ix)
