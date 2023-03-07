extends Resource

class_name NPC

const M: int = 0
const F: int = 1

const CORRUPT: int = 0
const HONEST: int = 1

const SUPPORT: int = 0
const NEUTRAL: int = 1
const OPPOSED: int = 2

const intel_threshold: int = 20

export var intel: int = 0
export var suspicion: int = 0
export var letter: String
export (int, "m", "f") var gender = 0
export (int, "corrupt", "honest") var corruption: int = CORRUPT
export (int, "support", "neutral", "opposed") var faction: = 1
export var scandalous: bool = false

export var npc_id: int = 0
export (Array, int) var connections: Array = [] # array of npc ids

 # return true when unlocking something with intel
func advance_intel() -> bool:
	intel += 1
	return intel % intel_threshold == 0

func advance_suspicion() -> bool:
	suspicion += 1
	if suspicion >= 100:
		suspicion = 100
		scandalous = true
		return true
	return false
