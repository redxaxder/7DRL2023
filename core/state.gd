extends Resource

class_name GameState

signal character_moved(new_pos, character)
signal grace(amount, quick)
signal dance_time(countdown)
signal dance_change(dances)

export var room_width: int = 10
export var room_height: int = 10

var dancers: Array = []
var current_dances: Array = [ PoolByteArray([0,1,2,3]), PoolByteArray([0,0,1,1]) ]

var cumulative_grace = 0
var dance_countdown = dance_duration
var dance_active = true

const grace_gain = 10
const player_id: int = 0 # player is always added to the array first!
const dance_duration = 30
const rest_duration = 10

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
	
	dance_countdown -= 1
	if dance_countdown <= 0:
		if dance_active:
			dance_active = false
			dance_countdown = rest_duration
			current_dances = []
		else:
			dance_active = true
			dance_countdown = dance_duration
			for _i in range(2):
				current_dances.append(Core.gen_steps_dance())
		emit_signal("dance_change", current_dances)
	emit_signal("dance_time", dance_countdown)
	

func trigger_grace():
	grace_triggered = true
	cumulative_grace += grace_gain
