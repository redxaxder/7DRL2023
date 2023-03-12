extends Resource

class_name GameState

signal character_moved(dancer, anim_kick_dir, was_shove)
signal got_intel(dancer)
signal grace(amount, quick)
signal dance_time(countdown)
signal dance_change(dances)
signal game_end()
signal pilfer(occupant)
signal write_log(log_text)
signal write_report(log_text)
signal begin_rest()
signal end_rest()

signal dance_ended()
signal dance_started()

signal song_start()
signal song_end()

export var room_width: int = 9
export var room_height: int = 9

var game_over: bool = false
var is_scandal: bool = false

var dancers: Array = []
var items: Array = [] # the names of the items belonging to each dancer
var location_index: Dictionary = {}
var current_dances: Array = []
var npcs: Array = []
var available_npcs: Dictionary = NPC_Names.name_map.duplicate(true)

var night = 1
var cumulative_grace = 0
var selected_ability = 0
var dance_countdown = rest_duration
var dance_active = false

const grace_gain = 10
const player_id: int = 0 # player is always added to the array first!
const dance_duration = 50
const rest_duration = 5

# special dancer ids
const NO_PARTNER = -2
const NO_OCCUPANT = -1


const num_initial_supporters = 3
const player_profile = preload("res://core/player_profile.tres")

func init():
	var keys = available_npcs.keys()
	for i in keys.size():
		var key = keys[i]
		var npc = NPC.new()
		var npc_entry = available_npcs[key]
		npc.name = key
		npc.letter = npc_entry[NPC_Names.character]
		npc.npc_id = i
		npc.portrait = NPC_Names.portraits[i]
		npc.gender = npc_entry[NPC_Names.gender]
		npc.resolve = (randi() % 11) * 5 + 40
		npc.gs = weakref(self)
#		npc.resolve = 10
		if npc_entry.has(NPC_Names.title):
			npc.title = npc_entry[NPC_Names.title]
		npc.connections = []
		npcs.append(npc)
		npc.corruption = randi() % 2
		for j in range(i):
			if randi() % 4 == 0:
				make_connection(i,j)
	var ids = range(npcs.size())
	ids.shuffle()
	for i in range(num_initial_supporters):
		var npc_id = ids[i]
		npcs[npc_id].faction = NPC.SUPPORT
	start_dance()

signal connection_made(id_a, id_b)
signal connection_broken(id_a, id_b)
func make_connection(id_a: int, id_b: int):
	var a = npcs[id_a]
	var b = npcs[id_b]
	if a.connections.find(id_b) < 0:
		a.connections.append(id_b)
	if b.connections.find(id_a) < 0:
		b.connections.append(id_a)
	emit_signal("connection_made", id_a, id_b)

func break_connection(id_a: int, id_b: int):
	npcs[id_a].connections.erase(id_b)
	npcs[id_b].connections.erase(id_a)
	emit_signal("connection_broken", id_a, id_b)

func player() -> Dancer:
	return dancers[player_id]

func start_dance(attendees = 7):
	emit_signal("write_log", "The sounds of cheerful conversation are heard as a new ball begins.")
	cumulative_grace = 0
	dance_countdown = rest_duration
	dance_active = false
	var player = Dancer.new()
	dancers = []
	items = []
	location_index = {}
	current_dances = []
	player.pos = get_free_space()
	add_dancer(player)
	player.npc = player_profile
	for attendee in throw_a_party(attendees):
		var dancer = Dancer.new()
		assert(attendee)
		dancer.npc = attendee
		assert(dancer.npc)
		attendee.dancer = weakref(dancer)
		dancer.pos = get_free_space()
		dancer.character = attendee.letter
		dancer.gender = attendee.gender
		add_dancer(dancer)
		assert(dancer.npc)
		if randi() % 5 <= 2:
			dancer.item_id = dancer.id

	for d in dancers:
		if d.id > 0:
			assert(d.npc)
	emit_signal("dance_started")
	emit_signal("begin_rest")

func throw_a_party(n: int) -> Array:  # Array of NPC
# warning-ignore:integer_division
	var needed_m = int(n) / int(2)
	var needed_f = n - needed_m
	var needed = [needed_m,needed_f]
	var attending = []
	var totals = [0,0]
	for npc in npcs:
		totals[npc.gender] += 1
	for npc in npcs:
		var attend_chance = float(needed[npc.gender]) / float(totals[npc.gender])
		if randf() < attend_chance:
			attending.append(npc)
			needed[npc.gender] -= 1
		totals[npc.gender] -= 1
	return attending

func add_dancer(d: Dancer):
	var id = dancers.size()
	dancers.append(d)
	d.id = id
	location_index[d.pos] = d.id
	emit_signal("character_moved", d, Dir.NO_DIR)

	var trinket = gen_trinket(d.gender)
	items.append(trinket)

func gen_trinket(gender: int) -> String:
	var pool = Trinkets.trinkets[gender]
	return pool[randi() % pool.size()]

func epilogue():
	emit_signal("game_end")

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
	emit_signal("character_moved", dancers[id], dir)
	emit_signal("character_moved", dancers[target], dir)

	var leader = m
	var follower = f
	if randi() % 20 == 0 && m != player_id:
		leader = f
		follower = m
	dancers[leader].leading = true
	dancers[follower].leading = false

	for x in [leader, follower]:
		for c in current_dances:
			dancers[x].start_dance(c)

	var follower_name = dancers[follower].npc.name
	if id == player_id:
		emit_signal("write_log", "You begin dancing with {0}.".format([follower_name]))
	else:
		var leader_name = dancers[leader].npc.name
		emit_signal("write_log", "{0} begins dancing with {1}.".format([leader_name, follower_name]))
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
	if player().has_partner():
		var partner = dancers[player().partner_id]
		if partner.npc.scandalous:
			emit_signal("write_log", "{0} slaps you across the face!".format([partner.npc.name]))
			cause_scandal(partner.id)
			return true
	var target_pos = player().pos + Dir.dir_to_vec(dir)
	if !in_bounds(target_pos):
		exit_dance()
		return true
	return try_move_dancer(player_id, dir)

func try_player_action(dir: int) -> Dictionary:
	var failed = {"moved": false, "acted": false}
	var target_pos = player().pos + Dir.dir_to_vec(dir)
	if !in_bounds(target_pos):
		return failed
	var occupant_id = location_index.get(target_pos, NO_OCCUPANT)
	if occupant_id == NO_OCCUPANT:
		return failed
	return try_interact(player_id, dir, occupant_id)

func try_move_dancer(id: int, dir: int) -> bool:
	if id < 0 || id >= dancers.size():
		return false
	if dir < 0 || dir >= 4:
		return false
	var dancer: Dancer = dancers[id]
	var partner_id = NO_PARTNER
	if dancer.has_partner():
		partner_id = dancer.partner_id
	var target_pos = dancer.pos + Dir.dir_to_vec(dir)
	if !in_bounds(target_pos):
		return false
	var occupant_id = location_index.get(target_pos, NO_OCCUPANT)
	if occupant_id != NO_OCCUPANT:
		if occupant_id == partner_id:
			return move_with_partner(id, dir)
		else:
			return false
	if dancer.has_partner():
		return move_with_partner(id, dir)
	else:
		return move_dancer_1(id, dir)

func valid_dir_for_move(id: int, dir: int) -> bool:
	var dancer: Dancer = dancers[id]
	var target_pos = dancer.pos + Dir.dir_to_vec(dir)
	if !in_bounds(target_pos):
		return false
	var occupant_id = location_index.get(target_pos, NO_OCCUPANT)
	return occupant_id == NO_OCCUPANT

func move_with_partner(leader_id: int, dir: int) -> bool:
	var leader = dancers[leader_id]
	var follower_id = leader.partner_id
	var follower = dancers[leader.partner_id]
	var spin = dir == leader.partner_dir
	leader.partner_dir = Dir.invert(dir)
# warning-ignore:return_value_discarded
	move_dancer_1(leader_id, dir, spin)
# warning-ignore:return_value_discarded
	move_dancer_1(follower_id, follower.partner_dir, spin)
	follower.partner_dir = dir
	return true

func move_dancer_1(id: int, dir: int, spin: bool = false, got_shoved: bool = false) -> bool:
	var dancer = dancers[id]
	var target_pos = dancer.pos + Dir.dir_to_vec(dir)
# warning-ignore:return_value_discarded
	if location_index.get(dancer.pos,NO_OCCUPANT) == id:
		location_index.erase(dancer.pos)
	dancer.pos = target_pos
	location_index[target_pos] = dancer.id
	var matches = dancer.step(dir)
	if dancer.id == player_id:
		for dance in matches:
			trigger_grace()
	var kick_dir = dir
	if spin:
		kick_dir = Dir.rot(kick_dir)
	emit_signal("character_moved", dancer, kick_dir, got_shoved)
	return true

func shove(_id, dir, target_id) -> bool:
	if valid_dir_for_move(target_id, dir):
		var dancer = dancers[target_id]
		dancer.stun = true
		if dancer.has_partner():
			dancers[dancer.partner_id].stun = true
		break_partners(target_id)
# warning-ignore:return_value_discarded
		move_dancer_1(target_id, dir, false, true)
# warning-ignore:return_value_discarded
		try_move_player(dir)
		return true
	return false

func break_partners(id: int):
	var dancer = dancers[id]
	if !dancer.has_partner():
		return
	var partner = dancers[dancer.partner_id]
	dancer.end_dance()
	partner.end_dance()
	emit_signal("character_moved", dancer, dancer.partner_dir)
	emit_signal("character_moved", partner, partner.partner_dir)

func is_dancer_solo(id):
	return !dancers[id].has_partner()

func try_interact(id, dir, target_id) -> Dictionary:
	var result = {"moved": false, "acted": false}
	var is_solo = is_dancer_solo(id)
	var target_solo = is_dancer_solo(target_id)
	var can_dance = dancers[id].gender != dancers[target_id].gender && dance_active
	var target = dancers[target_id]
	var target_name = target.npc.name
	if is_solo && target_solo && can_dance:
		make_partners(id, target_id, dir)
		result.acted = true
	elif id == player_id:
		var grace_level = Core.grace_info(cumulative_grace).level
		if Ability.costs[selected_ability] > grace_level:
			var ability_name = ""
			match selected_ability:
				Ability.TYPE.PILFER:
					ability_name = "pilfer"
				Ability.TYPE.SHOVE:
					ability_name = "shove"
			emit_signal("write_log", "You need to dance more before you can {0}.".format([ability_name]))
			return result
		match selected_ability:
			Ability.TYPE.SHOVE:
				if shove(id, dir, target_id):
					emit_signal("write_log", "You rudely shove {0} out of the way.".format([target_name]))
					cumulative_grace = 0
					emit_signal("grace", cumulative_grace)
					result.acted = true
					result.moved = true
			Ability.TYPE.PILFER:
				result.acted = trigger_pilfer(target_id)
				if !result.acted:
					emit_signal("write_log", "{0} isn't carrying anything you can steal.".format([target_name]))
				target.npc.discover_intel(NPC.INTEL.INVENTORY)
	return result

var grace_triggered = false

func tick_round():
	if !grace_triggered:
		var grace = Core.grace_info(cumulative_grace)
		cumulative_grace -= grace.level
	grace_triggered = false
	emit_signal("grace", cumulative_grace)

	#gain intel
	var ppos = player().pos
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
		dancers[i].roll_suspicion(grace.level, dist)

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
			emit_signal("write_log", "The song comes to an elegant end. The dance has ended.")
			emit_signal("begin_rest")
			emit_signal("song_end")
			dance_active = false
			dance_countdown = rest_duration
			current_dances = []
			for dancer in dancers:
				dancer.end_dance()
		else:
			emit_signal("write_log", "The music swells; the dance has begun!")
			emit_signal("song_start")
			emit_signal("end_rest")
			dance_active = true
			dance_countdown = dance_duration
			var dance1 = Core.gen_steps_dance()
			var dance2 = Core.gen_steps_dance()
			while Core.similar(dance1,dance2):
				dance2 = Core.gen_steps_dance()
			current_dances = [dance1, dance2]
		emit_signal("dance_change", current_dances)
	emit_signal("dance_time", dance_countdown)

func can_move_to(pos: Vector2, partner_id = NO_PARTNER) -> bool:
	var occpant_id = location_index.get(pos, NO_OCCUPANT)
	return in_bounds(pos) && (occpant_id == NO_OCCUPANT || occpant_id == partner_id)

func do_npc_turn(id: int) -> bool:
	var dancer: Dancer = dancers[id]
	if dancer.stun:
		dancer.stun = false
		return true
	if dancer.npc.scandalous and !dancer.has_partner():
		return npc_seek_player(id)
	elif !dance_active:
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

func npc_seek_player(id: int) -> bool:
	var dancer: Dancer = dancers[id]
	var player: Dancer = dancers[player_id]
	var distance: int = int(Core.manhattan(dancer.pos, player.pos))

	if distance == 1:
		cause_scandal(id)

	var candidates = []
	for d in Dir.approach(dancer.pos, player.pos):
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

func cause_scandal(npc_id: int):
	var name = dancers[npc_id].npc.name
	emit_signal("write_log", "{0} has caught on to your malfeasance!".format([name]))
	if night <= 6:
		emit_signal("write_report", "{0} has exposed your treachery. You will not be invited to further dances.".format([name]))
	game_over = true
	is_scandal = true
	emit_signal("game_end")
	exit_dance()

func trigger_grace():
	grace_triggered = true
	cumulative_grace += grace_gain

func trigger_pilfer(target_id: int):
	var info = Core.grace_info(cumulative_grace)
	var target:Dancer = dancers[target_id]
	var player: Dancer = dancers[player_id]
	if player.item_id != Trinkets.NO_ITEM || target.item_id != Trinkets.NO_ITEM:
		if target.item_id != Trinkets.NO_ITEM:
			emit_signal("write_log", "You stole {0} from {1}!".format([get_item_name(target.item_id), target.npc.name]))
		if player.item_id != Trinkets.NO_ITEM:
			emit_signal("write_log", "You slip {0} into {1}'s pocket.".format([get_item_name(player.item_id), target.npc.name]))
		var tmp = target.item_id
		target.item_id = player().item_id
		player().item_id = tmp
		cumulative_grace -= info.spend
		emit_signal("pilfer", target)
		return true
	else:
		return false

func exit_dance():
	emit_signal("write_log", "Eventually, the party winds down.")
	emit_signal("dance_ended")
	night += 1
	if night > 7:
		game_over = true
	var ordering = []
	for d in dancers:
		ordering.append(d)
	ordering.shuffle()
	for d in ordering:
		if d.id == player_id:
			continue
		if d.item_id != Trinkets.NO_ITEM && d.item_id != d.id:
			var holder = d.npc
			var owner = dancers[d.item_id].npc
			var is_connected = holder.connections.find(owner.npc_id) >= 0
			var item_name = get_item_name(d.item_id)
			match holder.corruption:
				NPC.CORRUPT:
					var message
					if is_connected:
						message = "{0} stole {1}. Their relationship has soured.".format([holder.name, item_name])
						break_connection(holder.npc_id, owner.npc_id)
					else:
						message = "{0} stole {1}. Their relationship was already bad.".format([holder.name, item_name])
					emit_signal("write_report", message)
				NPC.HONEST:
					var message
					if !is_connected:
						message = "{0} found and returned {2} to {1}. Their relationship has deepened.".format([holder.name, owner.name, item_name])
						make_connection(holder.npc_id,owner.npc_id)
					else:
						message = "{0} found and returned {2} to {1}. Their relationship was already good".format([holder.name, owner.name, item_name])
					emit_signal("write_report", message)
# warning-ignore:return_value_discarded
	do_contagion()
	emit_signal("song_end")
	night += 1
	if night > 7:
		game_over = true
	if game_over:
		for n in npcs:
			n.reveal_all_intel()
		while do_contagion():
			pass
		epilogue()
	else:
		for n in npcs:
			n.decay_suspicion()
		start_dance()

func do_contagion() -> bool:
	var changed = false
	var contagion_turns = range(npcs.size())
	contagion_turns.shuffle()
	for npc_id in contagion_turns:
		var support = get_npc_support(npc_id)
		var npc = npcs[npc_id]
		if support*100 >= npc.resolve && npc.faction != NPC.SUPPORT:
			npc.faction = NPC.SUPPORT
			emit_signal("write_log", "{0} has decided to support the coalition!".format([npc.name]));
			changed = true
	if did_win():
		epilogue()
	return changed

func did_win() -> bool:
	return get_required_support().size() == 0

func get_required_support() -> Array:
	var result = []
	for npc_id in range(npcs.size()):
		var npc = npcs[npc_id]
		if npc.faction != NPC.SUPPORT:
			result.append(npc)
	return result

func get_npc_support(npc_id: int) -> float:
	var npc: NPC = npcs[npc_id]
	var supporters = 0
	for neighbor_id in npc.connections:
		var n: NPC = npcs[neighbor_id]
		if n.faction == NPC.SUPPORT:
			supporters += 1

	var support = 0
	if npc.connections.size() > 0:
		support = float(supporters) / float(npc.connections.size())
	return support


func from_linear(ix: int) -> Vector2:
# warning-ignore:integer_division
	return Vector2(ix % room_width, ix / room_width)

func to_linear(v: Vector2) -> int:
	return room_width * int(v.y) + int(v.x)

func get_item_name(item_id: int) -> String:
	if item_id >= 0 && item_id < items.size():
		return "{0}'s {1}".format([dancers[item_id].name(), items[item_id]])
	return ""

func can_activate(d: Dance) -> bool:
	var dir = d.next_step()
	var player: Dancer = dancers[player_id]
	var target_pos = player.pos + Dir.dir_to_vec(dir)
	if !in_bounds(target_pos):
		return false
	var occupant_id = location_index.get(target_pos, NO_OCCUPANT)
	if occupant_id > NO_OCCUPANT && occupant_id != player.partner_id:
		return false
	return true

func count_revealed_vertices() -> int:
	var result: int = 0
	for n in npcs:
		var npc: NPC = n
		if npc.intel_known(NPC.INTEL.CONNECTIONS):
			result += 1
	return result
