extends Resource

class_name GameState

signal character_moved(new_pos, character)
signal grace(amount, quick)

export var room_width: int = 10
export var room_height: int = 10

var dancers: Array = []
var current_dances: Array = [ PoolByteArray([0,1,2,3]), PoolByteArray([0,0,1,1]) ]

var cumulative_grace = 0
const grace_gain = 10
const player_id: int = 0 # player is always added to the array first!

func init():
	pass

func add_dancer(d: Dancer):
	var id = dancers.size()
	dancers.append(d)
	d.id = id

func try_move_player(dir: int) -> bool:
	return try_move_dancer(player_id, dir)

func try_move_dancer(id: int, dir: int) -> bool:
	if id < 0 || id >= dancers.size():
		return false
	if dir < 0 || dir >= 4:
		return false
	var dancer: Dancer = dancers[id]
	var target_pos = dancer.pos + Dir.dir_to_vec(dir)
	# TODO: validate target pos
	dancer.pos = target_pos
	dancer.remember_move(dir)
	if dancer.id == player_id:
		for dance in current_dances:
			var orbit = D8.orbit(dance)
			for g in orbit.size():
				var progress = Core.steps_completed(dancer.recent_moves, orbit[g])
				if progress == 4:
					trigger_grace()
	emit_signal("character_moved", target_pos, dancer)
	return true

var grace_triggered = false

func tick_round():
	if !grace_triggered:
		var grace = Core.grace_info(cumulative_grace)
		cumulative_grace -= grace.level
	grace_triggered = false
	emit_signal("grace", cumulative_grace)

func trigger_grace():
	grace_triggered = true
	cumulative_grace += grace_gain
