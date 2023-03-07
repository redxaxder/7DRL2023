extends Resource

class_name NPC

const M: int = 0
const F: int = 1

export var intel: int = 0

func advance_intel():
	intel += 1
