tool
extends PanelContainer

export var dancer: Resource setget set_dancer

onready var dance_tracker = $VBoxContainer/dance_tracker
onready var glyph = $VBoxContainer/glyph
onready var intel = $VBoxContainer/intel
onready var suspicion = $VBoxContainer/suspicion
onready var faction = $VBoxContainer/faction
onready var character_name = $VBoxContainer/name
onready var title = $VBoxContainer/title

const DirString = preload("res://ui/dirstring.tscn")

func set_dancer(d: Dancer):
	dancer = d
	_refresh()

func _ready():
	intel.stages = [NPC.intel_threshold]
	_refresh()

func _refresh():
	if !dancer: return
	if !dance_tracker: return
	var d: Dancer = dancer

	if d.npc != null:
		intel.current = d.npc.intel
		intel.visible = true
		suspicion.current = d.npc.suspicion
		suspicion.visible = true
		faction.visible = d.npc.intel_known(NPC.INTEL.FACTION)
		faction.text = d.npc.describe_faction(d.npc.faction)
		character_name.visible = true
		character_name.text = d.npc.name
		title.visible = d.npc.title != ""
		title.text = d.npc.title
	else:
		intel.visible = false
		suspicion.visible = false
		faction.visible = false

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
		dstring.visible = dstring.progress > 0
		dance_tracker.add_child(dstring)

func compare_dances(l: Dance, r: Dance) -> bool:
	return l.compare(r) < 0

func snap():
	if intel: intel.snap()
	if suspicion: suspicion.snap()
