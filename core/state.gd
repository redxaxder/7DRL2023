extends Resource

class_name GameState

signal character_moved(character)
signal grace(amount, quick)
signal dance_time(countdown)
signal dance_change(dances)

export var room_width: int = 10
export var room_height: int = 10

var dancers: Array = []
var turn_order: Array = []
var location_index: Dictionary = {}
var current_dances: Array = []

var cumulative_grace = 0
var dance_countdown = rest_duration
var dance_active = false

const grace_gain = 10
const player_id: int = 0 # player is always added to the array first!
const dance_duration = 30
const rest_duration = 1

func add_dancer(d: Dancer):
	var id = dancers.size()
	dancers.append(d)
	d.id = id
	location_index[d.pos] = d.id
	turn_order.append(id)
	emit_signal("character_moved", d)

func make_partners(id: int, target: int, dir: int):
	var m
	var f
	if dancers[id].gender == Dancer.GENDER.M:
		m = id
		f = target
	else:
		m = target
		f = id
	dancers[m].partner_id = f
	dancers[f].partner_id = m
	dancers[id].partner_dir = dir
	dancers[target].partner_dir = Dir.invert(dir)
	emit_signal("character_moved", dancers[id])
	emit_signal("character_moved", dancers[target])

	var leader = m
	var follower = f
	if randi() % 20 == 0 && m != player_id:
		leader = f
		follower = m
	dancers[leader].leading = true
	dancers[follower].leading = false
	turn_order.erase(follower)

func get_free_space():
	var target: Vector2 = Vector2.ZERO
	var attempts = 100
	while attempts > 0:
		target.x = randi() % room_width
		target.y = randi() % room_height
		if location_index.has(target):
			continue
		return target

func in_bounds(pos: Vector2) -> bool:
	return \
		pos.x >= 0 && pos.x < room_width && \
		pos.y >= 0 && pos.y < room_height


func try_move_player(dir: int) -> bool:
	return try_move_dancer(player_id, dir)

func try_move_dancer(id: int, dir: int) -> bool:
	if id < 0 || id >= dancers.size():
		return false
	if dir < 0 || dir >= 4:
		return false
	var dancer: Dancer = dancers[id]
	var target_pos = dancer.pos + Dir.dir_to_vec(dir)
	if !in_bounds(target_pos):
		return false
	if location_index.has(target_pos):
		return try_interact(id, dir, location_index[target_pos])
	if dancer.has_partner():
		move_with_partner(id, dir)
	else:
		move_dancer(id, dir)
	return true

func move_with_partner(leader_id: int, dir: int):
	var leader = dancers[leader_id]
	var follower_id = leader.partner_id
	var follower = dancers[leader.partner_id]
	
	leader.partner_dir = Dir.invert(dir)
	move_dancer(leader_id, dir)
	move_dancer(follower_id, follower.partner_dir)
	follower.partner_dir = dir


func move_dancer(id: int, dir: int):
	var dancer = dancers[id]
	var target_pos = dancer.pos + Dir.dir_to_vec(dir)
# warning-ignore:return_value_discarded
	location_index.erase(dancer.pos)
	dancer.pos = target_pos
	location_index[target_pos] = dancer.id
	var matches = dancer.step(dir)
	if dancer.id == player_id:
		for _dance in matches:
			#TODO: branch on dance.type
			trigger_grace()
	emit_signal("character_moved", dancer)
	

func try_interact(id, dir, target_id) -> bool:
	var is_solo = !dancers[id].has_partner()
	var target_solo = !dancers[target_id].has_partner()
	var can_dance = dancers[id].gender != dancers[target_id].gender
	if is_solo && target_solo && can_dance:
		make_partners(id, target_id, dir)
		return true
	return false

var grace_triggered = false

func tick_round():
	if !grace_triggered:
		var grace = Core.grace_info(cumulative_grace)
		cumulative_grace -= grace.level
	grace_triggered = false
	emit_signal("grace", cumulative_grace)
	
	#move all dancers except the player
	for i in range(1, turn_order.size()):
		var id = turn_order[i]
# warning-ignore:return_value_discarded
		do_npc_turn(id)
	dance_countdown -= 1
	if dance_countdown <= 0:
		if dance_active:
			dance_active = false
			dance_countdown = rest_duration
			current_dances = []
			for dancer in dancers:
				dancer.end_dance()
		else:
			dance_active = true
			dance_countdown = dance_duration
			var dance1 = Core.gen_steps_dance()
			var dance2 = Core.gen_steps_dance()
			while Core.similar(dance1,dance2):
				dance2 = Core.gen_steps_dance()
			current_dances = [dance1, dance2]
			for d in dancers:
				for c in current_dances:
					d.start_dance(c)
		emit_signal("dance_change", current_dances)
	emit_signal("dance_time", dance_countdown)

# warning-ignore:unused_argument
func do_npc_turn(id: int) -> bool:
	var candidates = []
	for d in range(4):
		var target_pos = dancers[id].pos + Dir.dir_to_vec(d)
		if !in_bounds(target_pos):
			continue
		if location_index.has(target_pos):
			continue #TODO: handle swapping with partner
		candidates.append(d)

	# ask the dancer to JUDGE each dir
	# the judgement should be an integer reflecting preference for that dir
	var judgements = []
	var best_score = 0
	for d in candidates:
		var j = dancers[id].evaluate(d)
		judgements.append(j)
		best_score = max(best_score, j)

	# among the dirs which are tied for best, pick one at random
	var good_candidates = []
	for i in candidates.size():
		if judgements[i] == best_score:
			good_candidates.append(candidates[i])
	
	if good_candidates.size() == 0:
		return false # probably cornered or something
	
	good_candidates.shuffle()
	var dir = good_candidates[0]
	return try_move_dancer(id, dir)

func trigger_grace():
	grace_triggered = true
	cumulative_grace += grace_gain
