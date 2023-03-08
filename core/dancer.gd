extends Resource

class_name Dancer

const Dance = preload("res://core/dance.gd")

signal suspicion_gained
signal intel_gained

export var character: String = "R"
export (Array, Resource) var dance_tracker: Array
export (int, "M","F") var gender: int
export var npc: Resource

var pos: Vector2 = Vector2(0,0)
var id: int = -1

var partner_id: int = -1
var partner_dir: int = 0
var leading: bool = false
var stun = false

signal start_dance_tracker()

func has_partner() -> bool:
	return partner_id >= 0

func takes_turn() -> bool:
	return partner_id < 0 || leading

func advance_intel():
	if npc != null:
		emit_signal("intel_gained")
		npc.advance_intel()

const suspicion_n: float = 7.0
func roll_suspicion(grace: float, distance: float) -> bool:
	var sneaky = (grace + distance) * distance
	var f = suspicion_n / (suspicion_n + sneaky)
	if f < 0.3:
		return false
	elif randf() < f:
		emit_signal("suspicion_gained")
		return npc.advance_suspicion()
	else:
		return false

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
	if !has_partner():
		dance_tracker= []
		return
	var orbit = D8.orbit(steps)
	for g in orbit.size():
		var d = Dance.new(orbit[g], dance_type, g)
		dance_tracker.append(d)
	if id == 0: #player
		emit_signal("start_dance_tracker")

func end_dance():
	dance_tracker = []
	partner_id = -1
