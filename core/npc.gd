extends Resource

class_name NPC

const M: int = 0
const F: int = 1

export var intel: int = 0
export var suspicion: int = 0

 # return true when unlocking something with intel
func advance_intel() -> bool:
	intel += 1
	return false
