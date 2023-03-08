tool
extends HBoxContainer

export var count: int = 0 setget set_count

func set_count(x):
	count = x
	_refresh()

func _ready():
	_refresh()

func _refresh():
	for i in get_child_count():
		get_child(i).visible = i < count
