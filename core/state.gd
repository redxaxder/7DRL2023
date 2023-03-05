extends Resource

class_name GameState

signal character_moved(new_pos, character)

export var room_width: int = 10
export var room_height: int = 10

var dancers: Array = []
var current_dances: Array = [ PoolByteArray([0,1,2,3]) ]

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
	emit_signal("character_moved", target_pos, dancer)
	return true
	
	

