extends Resource

class_name Dancer

const Dance = preload("res://core/dance.gd")

export var pos: Vector2 = Vector2(0,0)
export var id: int = 0

var dance_tracker: Array = []

func step(dir: int) -> Array:
	var matches = []
	for dance in dance_tracker:
		var matched = dance.transition(dir)
		if matched == Dance.MATCH.FINISH:
			matches.append(dance)
	return matches

func start_dance(steps, dance_type = Dance.TYPE.GRACE):
	var orbit = D8.orbit(steps)
	for g in orbit.size():
		var d = Dance.new(orbit[g], dance_type, g)
		dance_tracker.append(d)

func end_dance():
	dance_tracker = []
