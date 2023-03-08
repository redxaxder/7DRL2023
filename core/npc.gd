extends Resource

class_name NPC

const M: int = 0
const F: int = 1

const CORRUPT: int = 0
const HONEST: int = 1

const SUPPORT: int = 0
const NEUTRAL: int = 1
const OPPOSED: int = 2

enum INTEL{ FACTION=1, CONNECTIONS=2, RESOLVE=4, CORRUPTION=8, INVENTORY = 16}


const intel_threshold: int = 20

export var intel: int = 0
export (int, FLAGS, "faction","connections","resolve","corruption", "inventory") var known_intel = 0
export var suspicion: int = 0
export var letter: String
export (int, "m", "f") var gender = 0
export (int, "corrupt", "honest") var corruption: int = CORRUPT
export (int, "support", "neutral", "opposed") var faction: = 1
export var scandalous: bool = false
export var resolve: int = 70

export var npc_id: int = 0
export (Array, int) var connections: Array = [] # array of npc ids

signal intel_level_up(npc, intel_type)
func intel_known(intel_type: int) -> bool:
	return known_intel & intel_type > 0

 # return true when unlocking something with intel
func advance_intel() -> bool:
	intel += 1
	if intel % intel_threshold == 0:
		intel_level += 1
		emit_signal("intel_level_up", self, intel_level)
		return true
	return false

func advance_suspicion() -> bool:
	suspicion += 1
	if suspicion >= 100:
		suspicion = 100
		scandalous = true
		return true
	return false

func describe_faction(faction_id: int) -> String:
	if faction_id == SUPPORT:
		return "Support"
	elif faction_id == NEUTRAL:
		return "Neutral"
	elif faction_id == OPPOSED:
		return "Opposed"
	else:
		return ""
