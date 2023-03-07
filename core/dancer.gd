extends Resource

class_name Dancer

const Dance = preload("res://core/dance.gd")

export var character: String = "R"
export (Array, Resource) var dance_tracker: Array
export (int, "M","F") var gender: int

var pos: Vector2 = Vector2(0,0)
var id: int = -1

var partner_id: int = -1
var partner_dir: int = 0
var leading: bool = false


func has_partner() -> bool:
	return partner_id >= 0

func takes_turn() -> bool:
	return partner_id < 0 || leading

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
	partner_id = -1
