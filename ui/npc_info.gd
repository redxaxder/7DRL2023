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

	glyph.text = d.character
	glyph.modulate = UIConstants.gender_color(d.gender)
	
	for c in dance_tracker.get_children():
		c.queue_free()
	var dances = []
	for dance in d.dance_tracker:
		dances.append(dance)
	dances.sort_custom(self,"compare_dances")
	for dance in dances:
		var dstring = DirString.instance()
		dstring.steps = dance.steps
		dstring.progress = dance.progress()
		dance_tracker.add_child(dstring)

func compare_dances(l: Dance, r: Dance) -> bool:
	return l.compare(r) < 0