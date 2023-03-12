tool
extends Resource

class_name NPC

const M: int = 0
const F: int = 1
const she = ["he", "she"]
const She = ["He", "She"]
const her = ["his", "her"]

const CORRUPT: int = 0
const HONEST: int = 1

const SUPPORT: int = 0
const NEUTRAL: int = 1
const OPPOSED: int = 2

enum INTEL{ FACTION=1, CONNECTIONS=2, RESOLVE=4, CORRUPTION=8, INVENTORY = 16}
const FULL_INTEL = INTEL.FACTION | INTEL.CONNECTIONS | INTEL.RESOLVE | INTEL.CORRUPTION | INTEL.INVENTORY


const intel_threshold: int = 40

export var intel: int = 0
export (int, FLAGS, "faction","connections","resolve","corruption", "inventory") var known_intel = 0
export var suspicion: int = 0
export var letter: String
var dancer: WeakRef = null

export (int, "m", "f") var gender = 0
export (int, "corrupt", "honest") var corruption: int = CORRUPT
export (int, "support", "neutral", "opposed") var faction: = NEUTRAL setget set_faction
export var scandalous: bool = false
export var resolve: int = 70
export var name: String = ""
export var title: String = ""
export var is_player = false
export var portrait: Texture

export var npc_id: int = 0
export var spouse_id: int = -1 #TODO: make spouses matter

export (Array, int) var connections: Array = [] # array of npc ids

signal intel_level_up(npc, intel_type)
signal faction_changed()
signal write_log(log_text)
signal scandal(npc)

 # return true when unlocking something with intel
func advance_intel() -> bool:
	intel += 1
	if intel % intel_threshold == 0:
		var intel_options = []
		for i in intel_priority:
			if !intel_known(i):
				intel_options.append(i)
		if intel_options.size() == 0:
			return false
		discover_intel(intel_options[0])
	return false

const intel_priority: Array = [INTEL.FACTION, INTEL.CONNECTIONS, INTEL.RESOLVE, INTEL.CORRUPTION, INTEL.INVENTORY]

func set_faction(new_faction: int):
	faction = new_faction
	emit_signal("faction_changed")

func intel_known(intel_type: int) -> bool:
	return known_intel & intel_type > 0

func is_full_intel() -> bool:
	return known_intel == FULL_INTEL

func discover_intel(intel_type: int):
	if intel_type > 0 && known_intel & intel_type ==  0:
		known_intel = known_intel | intel_type
		emit_signal("intel_level_up", self, intel_type)
		emit_signal("write_log", "You've acquired some intel!")
		if intel_type == INTEL.CONNECTIONS:
			emit_signal("write_log", "You've learned about {0}'s connections.".format([name]))
		elif intel_type == INTEL.CORRUPTION:
			if corruption == CORRUPT:
				emit_signal("write_log", "{0} seems a little unscrupulous.".format([name]))
			else:
				emit_signal("write_log", "{0} is the honest sort!".format([name]))
		elif intel_type == INTEL.FACTION:
			emit_signal("write_log", "{0}'s political leanings are clear to you now.".format([name]))
		elif intel_type == INTEL.INVENTORY:
			emit_signal("write_log", "You know what {0} came to the ball with.".format([name]))
		elif intel_type == INTEL.RESOLVE:
			emit_signal("write_log", "You have a good idea of the strength of {0}'s convictions.".format([name]))

func advance_suspicion() -> bool:
	suspicion += 1
	if suspicion >= 100:
		suspicion = 100
		scandalous = true
		emit_signal("write_log", "{0} is suspicious of you!".format([name]))
		emit_signal("scandal")
		return true
	return false

func decay_suspicion():
	if suspicion > 0:
		suspicion -= int(suspicion / 2)
	scandalous = false

const faction_name =  ["Supporter", "Neutral", "Opposition"]
const _faction_tooltip = [\
	"{0} is helping assemble the seventh coalition\nTheir help will be essential in securing Napoleon's defeat",\
	"{0} is not helping assemble the seventh coalition\nA minor obstacle",\
	"{0} is interfering with the creation of the seventh coalition"
	]
func faction_tooltip():
	return _faction_tooltip[faction].format([She[gender]])

const corruption_name = ["Corrupt", "Honest"]
const _corruption_tooltip = [\
	"{0} will steal anything given an opportunity\nHow can I use this to my advantage?",\
	"{0} is above petty theft\nA useful character tait"\
	]
func corruption_tooltip():
	return _corruption_tooltip[corruption].format([She[gender]])
