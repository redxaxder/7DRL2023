tool
extends MarginContainer


export var npc: Resource setget set_npc
export var displayed_faction: int = -1 setget set_displayed_faction
export var support: float setget set_support
#export var support_dubious: bool setget set_support_dubious
#export var opposition: float setget set_opposition
export var faction_colors: PoolColorArray = PoolColorArray([Color(0.227451, 0.466667, 0.772549), Color(0.66, 0.6435, 0.6204), Color(0.823529, 0.098039, 0.098039)])

onready var support_label = $VBoxContainer/support_percent
onready var support_guage = $VBoxContainer/MarginContainer/support
onready var opposition_label = $VBoxContainer/opposed_percent
onready var opposition_guage = $VBoxContainer/MarginContainer2/opposition
onready var faction = $VBoxContainer/CenterContainer/faction
onready var label = $VBoxContainer/CenterContainer/MarginContainer/Label
onready var ticks = [$VBoxContainer/MarginContainer/TickMark, $VBoxContainer/MarginContainer2/TickMark]

# warning-ignore:unused_signal
signal clicked

func set_npc(x):
	npc = x
	_refresh()

func set_displayed_faction(x):
	displayed_faction = x
	_refresh()

func set_support(x):
	support = x
	_refresh()

#func set_support_dubious(x):
#	support_dubious = x
#	_refresh()
#
#func set_opposition(x):
#	opposition = x
#	_refresh()

func _ready():
# warning-ignore:return_value_discarded
	$Button.connect("button_down", self, "emit_signal", ["clicked"])
	_refresh()

func _refresh():
	if !npc:
		return
	var n: NPC = npc
	if label:
		label.text = n.letter
		label.modulate = UIConstants.gender_color(n.gender)
	if support_guage:
		support_guage.current = support
#		if npc.intel_known(NPC.INTEL.SUPPORT):
#			support_guage.modulate = Color(1,1,1,1)
#		else:
#			support_guage.modulate = Color(0,0,0,0)
	if support_label:
		support_label.text = "{0}% ?".format([int(support)])
#		if npc.intel_known(NPC.INTEL.SUPPORT):
#			support_label.modulate = Color(1,1,1,1)
#		else:
#			support_label.modulate = Color(0,0,0,0)
#	if opposition_guage:
#		opposition_guage.current = opposition
#	if opposition_label:
#		opposition_label.text = "{0}%".format([int(opposition)])
	if faction:
		if displayed_faction < 0 || displayed_faction >= faction_colors.size():
			faction.color = Color(0,0,0,0)
		else:
			faction.color = faction_colors[displayed_faction]
	if ticks:
		for tick in ticks:
			if tick:
				tick.visible = n.intel_known(NPC.INTEL.RESOLVE)
				tick.percentage = float(n.resolve) / 100.0
	var enough = "enough"
	if n.intel_known(NPC.INTEL.RESOLVE):
		enough = "{0}%".format([n.resolve])
	var she = NPC.she[n.gender]	
	hint_tooltip = "If {0} of her contacts join my cause\n{1} will as well".format([enough, she])
