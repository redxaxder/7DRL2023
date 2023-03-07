extends Resource

class_name NPC

const M: int = 0
const F: int = 1
const intel_threshold: int = 20


export var intel: int = 0
export var suspicion: int = 0
export var scandalous: bool = false

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
