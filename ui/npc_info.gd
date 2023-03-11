extends PanelContainer

export var dancer: Resource setget set_dancer
export var npc: Resource setget set_npc

onready var dance_tracker = $VBoxContainer/dance_tracker
onready var glyph = $VBoxContainer/glyph
onready var intel = $VBoxContainer/intel
onready var suspicion = $VBoxContainer/suspicion
onready var faction = $VBoxContainer/faction
onready var corruption = $VBoxContainer/corruption
onready var character_name = $VBoxContainer/name
onready var title = $VBoxContainer/title

const DirString = preload("res://ui/dirstring.tscn")

func set_dancer(d: Dancer):
	dancer = d
	npc = null
	if d:
		npc = d.npc
	_refresh()

func set_npc(n: NPC):
	npc = n
	dancer = null
	if npc && npc.dancer:
		var r =  npc.dancer.get_ref()
		if r:
			dancer = r
	_refresh()

func _ready():
	intel.stages = [NPC.intel_threshold]
	_refresh()

func _refresh():
	if !intel: return
	if npc != null:
		intel.current = npc.intel
		intel.visible = !npc.is_player
		suspicion.current = npc.suspicion
		suspicion.visible = !npc.is_player
		faction.visible = npc.intel_known(NPC.INTEL.FACTION) && !npc.is_player
		faction.text = NPC.faction_name[npc.faction]
		faction.hint_tooltip = NPC.faction_tooltip[npc.faction]
		corruption.visible = npc.intel_known(NPC.INTEL.CORRUPTION) && !npc.is_player
		corruption.text = NPC.corruption_name[npc.corruption]
		corruption.hint_tooltip = NPC.corruption_tooltip[npc.corruption]
		character_name.visible = true
		character_name.text = npc.name
		title.visible = npc.title != ""
		title.text = npc.title
		glyph.text = npc.letter
		glyph.modulate = UIConstants.gender_color(npc.gender)
	else:
		intel.visible = false
		suspicion.visible = false
		faction.visible = false
		character_name.visible = false
		title.visible = false
	if dancer:
		var sus_percent = int(dancer.sus_chance * 100)
		suspicion.hint_tooltip = "Suspicion\nHow strongly this person suspects you are a spy. \nDon't let it reach a critical level. Based on your current \nposition and how well you are dancing, there is a {0}% \nchance for this to increase each turn.".format([sus_percent])

	if dance_tracker && dancer:
		for c in dance_tracker.get_children():
			c.queue_free()
		var dances = []
		if dancer.leading:
			for dance in dancer.dance_tracker:
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
