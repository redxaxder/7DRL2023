extends Resource

class_name Dancer

const Dance = preload("res://core/dance.gd")

var pos: Vector2 = Vector2(0,0)
var id: int = -1
var character: String = "R"

var partner_id: int = -1
var leading: bool = false

var dance_tracker: Array = []

func step(dir: int) -> Array:
	var matches = []
	for dance in dance_tracker:
		var matched = dance.transition(dir)
		if matched == Dance.MATCH.FINISH:
			matches.append(dance)
	return matches

# returns the longest match that would be created by this move
func evaluate(dir: int) -> int:
	var result = 0
	for dance in dance_tracker:
		result = max(result, dance.evaluate(dir))
	return result

func start_dance(steps, dance_type = Dance.TYPE.GRACE):
	var orbit = D8.orbit(steps)
	for g in orbit.size():
		var d = Dance.new(orbit[g], dance_type, g)
		dance_tracker.append(d)

func end_dance():
	dance_tracker = []
