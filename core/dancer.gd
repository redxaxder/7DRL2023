tool
extends Resource

class_name Dancer

const Dance = preload("res://core/dance.gd")

signal suspicion_gained
signal intel_gained

export var character: String = "C"
export (Array, Resource) var dance_tracker: Array
export (int, "M","F") var gender: int
export var npc: Resource

var pos: Vector2 = Vector2(0,0)
var id: int = -1
var item_id = Trinkets.NO_ITEM

var partner_id: int = -1
var partner_dir: int = 0
var leading: bool = false
var stun = false

var sus_chance: float = 0

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
	sus_chance = f
	if f < 0.3:
		sus_chance = 0
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

func name() -> String:
	if npc:
		return npc.name
	else:
		return ""

func start_dance(steps, dance_type = Dance.TYPE.GRACE, ability_dir: Vector2 = Vector2.ZERO):
	if !has_partner():
		dance_tracker= []
		return
	var orbit = D8.orbit(steps)
	for g in orbit.size():
		var modified_dir = D8.act_vec(g, ability_dir)
		var d = Dance.new(orbit[g], dance_type, g, modified_dir)
		dance_tracker.append(d)
	if id == 0: #player
		emit_signal("start_dance_tracker")

func end_dance():
	dance_tracker = []
	partner_id = -1
