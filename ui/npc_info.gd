extends PanelContainer

export var dancer: Resource setget set_dancer
export var npc: Resource setget set_npc
var gamestate = null

onready var dance_tracker = $VBoxContainer/dance_tracker
onready var glyph = $VBoxContainer/glyph
onready var intel = $VBoxContainer/intel
onready var suspicion = $VBoxContainer/suspicion
onready var faction = $VBoxContainer/faction
onready var corruption = $VBoxContainer/corruption
onready var resolve = $VBoxContainer/resolve
onready var item_panel = $VBoxContainer/item
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
		intel.visible = !npc.is_player
		if npc.is_full_intel():
			intel.stages = [1]
			intel.show_numbers = false
		else:
			intel.current = npc.intel
			intel.stages = [NPC.intel_threshold]
			intel.show_numbers = true
		suspicion.current = npc.suspicion
		suspicion.visible = !npc.is_player
		faction.visible = !npc.is_player
		faction.text = NPC.faction_name[npc.faction]
		faction.hint_tooltip = NPC.faction_tooltip[npc.faction]
		if !npc.intel_known(NPC.INTEL.FACTION):
			faction.text = "???"
			faction.hint_tooltip = "I do not know their alleigence\nAre they going to help me? Or get in the way?"
		corruption.visible = !npc.is_player
		corruption.text = NPC.corruption_name[npc.corruption]
		corruption.hint_tooltip = NPC.corruption_tooltip[npc.corruption]
		if !npc.intel_known(NPC.INTEL.CORRUPTION):
			corruption.text = "???"
			corruption.hint_tooltip = "What kind of person are you, {0}?\nI need to learn more about their personality".format([npc.name])
		character_name.visible = true
		character_name.text = npc.name

		item_panel.visible = !npc.is_player && !!gamestate
		if gamestate && dancer:
			var item_id = dancer.item_id
			if item_id == Trinkets.NO_ITEM:
				item_panel.text = "No item"
				item_panel.hint_tooltip = ""
#				item_panel.hint_toolip = "They are not carrying anything worth stealing"
			else:
				item_panel.text = gamestate.get_item_name(item_id)
				item_panel.hint_tooltip = ""
				if item_id != dancer.id:
					item_panel.hint_tooltip = "I wonder how that got there"
			if !npc.intel_known(NPC.INTEL.INVENTORY):
				item_panel.text = "Item: ???"
				item_panel.hint_tooltip = "I do not know what they are carrying"

		resolve.visible = !npc.is_player
		resolve.text = "Resolve: {0}%".format([npc.resolve])
		resolve.hint_tooltip = "If enough of your friends join my cause\nwon't your mind be made up for you?"
		if !npc.intel_known(NPC.INTEL.RESOLVE):
			resolve.text = "Resolve: ???"
			resolve.hint_tooltip = "I do not know stubborn they are"

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
