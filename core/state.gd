extends Resource

class_name GameState

signal character_moved(dancer)
signal got_intel(dancer)
signal grace(amount, quick)
signal dance_time(countdown)
signal dance_change(dances)

export var room_width: int = 10
export var room_height: int = 10

var dancers: Array = []
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
	emit_signal("character_moved", d)

func make_partners(id: int, target: int, dir: int):
	var m
	var f
	if dancers[id].gender == NPC.M:
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

	for c in current_dances:
		dancers[leader].start_dance(c)
		dancers[follower].start_dance(c)

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
	var partner_id = -2
	if dancer.has_partner():
		partner_id = dancer.partner_id
	var target_pos = dancer.pos + Dir.dir_to_vec(dir)
	if !in_bounds(target_pos):
		return false
	var occupant_id = location_index.get(target_pos, -1)
	if occupant_id != -1:
		if occupant_id == partner_id:
			return move_with_partner(id, dir)
		else:
			return try_interact(id, dir, occupant_id)
	if dancer.has_partner():
		return move_with_partner(id, dir)
	else:
		return move_dancer_1(id, dir)

func valid_dir_for_move(id: int, dir: int) -> bool:
	var dancer: Dancer = dancers[id]
	var target_pos = dancer.pos + Dir.dir_to_vec(dir)
	if !in_bounds(target_pos):
		return false
	var occupant_id = location_index.get(target_pos, -1)
	return occupant_id == -1

func move_with_partner(leader_id: int, dir: int) -> bool:
	var leader = dancers[leader_id]
	var follower_id = leader.partner_id
	var follower = dancers[leader.partner_id]

	leader.partner_dir = Dir.invert(dir)
# warning-ignore:return_value_discarded
	move_dancer_1(leader_id, dir)
# warning-ignore:return_value_discarded
	move_dancer_1(follower_id, follower.partner_dir)
	follower.partner_dir = dir
	return true

func move_dancer_1(id: int, dir: int) -> bool:
	var dancer = dancers[id]
	var target_pos = dancer.pos + Dir.dir_to_vec(dir)
# warning-ignore:return_value_discarded
	if location_index.get(dancer.pos,-1) == id:
		location_index.erase(dancer.pos)
	dancer.pos = target_pos
	location_index[target_pos] = dancer.id
	var matches = dancer.step(dir)
	if dancer.id == player_id:
		for _dance in matches:
			#TODO: branch on dance.type
			trigger_grace()
	emit_signal("character_moved", dancer)
	return true

func shove(id, dir, target_id) -> bool:
	#TODO generate suspicion
	if is_dancer_solo(target_id):
		if try_move_dancer(target_id, dir):
			try_move_player(dir)
			return true
		else:
			return false
	else:
		if valid_dir_for_move(target_id, dir):
			break_partners(target_id)
			try_move_dancer(target_id, dir)
			try_move_player(dir)
			return true
		else:
			return false

func break_partners(id: int):
	var dancer = dancers[id]
	var partner = dancers[dancer.partner_id]
	dancer.end_dance()
	partner.end_dance()
	emit_signal("character_moved", dancer)
	emit_signal("character_moved", partner)

func is_dancer_solo(id):
	return !dancers[id].has_partner()

func try_interact(id, dir, target_id) -> bool:
	var is_solo = is_dancer_solo(id)
	var target_solo = is_dancer_solo(target_id)
	var can_dance = dancers[id].gender != dancers[target_id].gender
	if is_solo && target_solo && can_dance:
		make_partners(id, target_id, dir)
		return true
	elif id == player_id:
		return shove(id, dir, target_id)
	return false

var grace_triggered = false

func tick_round():
	if !grace_triggered:
		var grace = Core.grace_info(cumulative_grace)
		cumulative_grace -= grace.level
	grace_triggered = false
	emit_signal("grace", cumulative_grace)

	#gain intel
	var ppos = dancers[player_id].pos
	for i in range(1, dancers.size()):
		var los = Core.los(ppos, dancers[i].pos)
		var occluded = false
		for pos in los:
			if location_index.has(pos):
				occluded = true
				break
		if !occluded:
			dancers[i].advance_intel()
			emit_signal("got_intel", dancers[i])
	
	# roll suspicion
	var grace = Core.grace_info(cumulative_grace)
	for i in range(1, dancers.size()):
		var v = (ppos - dancers[i].pos).abs()
		var dist = max(v.x,v.y)
		var suspicion_critical = dancers[i].roll_suspicion(grace.level, dist)
		if suspicion_critical:
			print("very sus!")

	#move npcs
	var turn_order = []
	for i in range(1, dancers.size()):
		if dancers[i].takes_turn():
			turn_order.append(i)
	turn_order.shuffle()
	for id in turn_order:
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
		emit_signal("dance_change", current_dances)
	emit_signal("dance_time", dance_countdown)


func can_move_to(pos: Vector2, partner_id = -2) -> bool:
	var occpant_id = location_index.get(pos, -1)
	return in_bounds(pos) && (occpant_id == -1 || occpant_id == partner_id)

func do_npc_turn(id: int) -> bool:
	var dancer: Dancer = dancers[id]
	if !dance_active:
		return npc_mill_around(id)
	elif dancer.has_partner():
		return npc_dance(id)
	else:
		return npc_seek_partner(id)

func npc_dance(id: int) -> bool:
	var candidates = []
	for d in range(4):
		var target_pos = dancers[id].pos + Dir.dir_to_vec(d)
		if can_move_to(target_pos, dancers[id].partner_id):
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

func npc_seek_partner(id: int) -> bool:
	var dancer: Dancer = dancers[id]
	var g = dancer.gender
	var targets = {}
	for t in dancers:
		if t.gender == g: continue
		if t.has_partner(): continue
		var d:int = int(Core.manhattan(dancer.pos, t.pos))
		if targets.has(d):
			targets[d].append(t)
		else:
			targets[d] = [t]

	var adjacent_targets = targets.get(1,[])
	adjacent_targets.shuffle()
	for t in adjacent_targets:
		if t.id != player_id:
			var dirs = Dir.approach(dancer.pos, t.pos)
			make_partners(id, t.id, dirs[0])
			return true

	var distances = targets.keys()
	if distances.size() == 0:
		return npc_mill_around(id)
	distances.sort()
	var closest_targets = targets[distances[0]]

	var candidates = []
	for t in closest_targets:
		for d in Dir.approach(dancer.pos, t.pos):
			var target_pos = Dir.mv(dancer.pos, d)
			if can_move_to(target_pos):
				candidates.append(d)
	if candidates.size() == 0:
		return npc_mill_around(id)
	candidates.shuffle()
	return try_move_dancer(id, candidates[0])

func npc_mill_around(id: int) -> bool:
	var candidates = []
	for d in range(4):
		var target_pos = Dir.mv(dancers[id].pos, d)
		if can_move_to(target_pos):
			candidates.append(d)
	if candidates.size() == 0:
		return false # didn't move!
	candidates.shuffle()
	var dir = candidates[0]
	return try_move_dancer(id, dir)

func trigger_grace():
	grace_triggered = true
	cumulative_grace += grace_gain

func from_linear(ix: int) -> Vector2:
# warning-ignore:integer_division
	return Vector2(ix % room_width, ix / room_width)

func to_linear(v: Vector2) -> int:
	return room_width * int(v.y) + int(v.x)

func make_dijkstra(targets: Array) -> PoolIntArray:
	var results: Array = []
	results.resize(room_width * room_height)
	for i in results.size():
		results[i] = 9999
	var frontier = []
	for t in targets:
		var ix = to_linear(t)
		results[ix] = 0
		frontier.append(ix)
	while frontier.size() > 0:
		var next_frontier = []
		for f in frontier:
			var value = results[f]
			var neighbors = []
			var p = from_linear(f)
			for d in range(4):
				var t = p + Dir.dir_to_vec(d)
				if in_bounds(t):
					neighbors.append(to_linear(t))
			for n in neighbors:
				if value + 1 < results[n]:
					results[n] = value + 1
					next_frontier.append(n)
		frontier = next_frontier
	return PoolIntArray(results)

