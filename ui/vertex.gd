extends MarginContainer


export var npc: Resource setget set_npc
export var support: float setget set_support
export var opposition: float setget set_opposition
export var faction_colors: PoolColorArray = PoolColorArray([Color(0.227451, 0.466667, 0.772549), Color(0.66, 0.6435, 0.6204), Color(0.823529, 0.098039, 0.098039)])

onready var support_guage = $VBoxContainer/MarginContainer/support
onready var opposition_guage = $VBoxContainer/MarginContainer2/opposition
onready var faction = $VBoxContainer/CenterContainer/faction
onready var label = $VBoxContainer/CenterContainer/MarginContainer/Label

func set_npc(x):
	npc = x
	_refresh()

func set_support(x):
	support = x
	_refresh()

func set_opposition(x):
	opposition = x
	_refresh()

func _ready():
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
	if opposition_guage:
		opposition_guage.current = opposition
	if faction:
		faction.color = faction_colors[npc.faction]

