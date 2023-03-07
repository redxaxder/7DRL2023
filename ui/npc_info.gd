tool
extends PanelContainer

export var dancer: Resource setget set_dancer

onready var dance_tracker = $VBoxContainer/dance_tracker
onready var glyph = $VBoxContainer/glyph

const DirString = preload("res://ui/dirstring.tscn")

func set_dancer(d: Dancer):
	dancer = d
	_refresh()

func _ready():
	_refresh()

func _refresh():
	if !dancer: return
	if !dance_tracker: return
	var d: Dancer = dancer

	glyph.modulate = UIConstants.gender_color(d.gender)
	
	for c in dance_tracker.get_children():
		c.queue_free()
	for dance in d.dance_tracker:
		var dstring = DirString.instance()
		dstring.steps = dance.steps
		dstring.progress = dance.progress()
		dance_tracker.add_child(dstring)
