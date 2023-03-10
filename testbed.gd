extends Control

var gamestate: GameState = GameState.new()

onready var dance_floor = $dance/MarginContainer/Control/dance_floor
onready var dance_countdown = $dance_countdown
onready var dance_match = $dance_match
onready var dance_floor_background = $dance/MarginContainer/dance_floor_background
onready var grace = $grace
onready var grace_guage = $grace/grace_guage
onready var npc_info = $npc_info
onready var connection_panel = $PanelContainer
onready var connection_graph = $PanelContainer/springy_graph
onready var view_connections = $view_connections
onready var inventory = $inventory
onready var inventory_text = $inventory/Label
onready var ability_selector = $ability_selector
onready var logger = $log
onready var dance_gauge = $DanceTimer
onready var rest_gauge = $RestTimer
onready var dance_icon = $DanceIcon
onready var rest_icon = $RestIcon
onready var report = $report
onready var report_log = report.rlog
onready var done = $done

var glyphs: Array = []

const Vertex = preload("res://ui/vertex.tscn")

func _ready():
# warning-ignore:return_value_discarded
	gamestate.connect("character_moved", self, "_on_character_moved", [], CONNECT_DEFERRED)
# warning-ignore:return_value_discarded
	gamestate.connect("grace", self, "_on_grace_changed")
# warning-ignore:return_value_discarded
	gamestate.connect("dance_time", self, "_on_dance_timer")
# warning-ignore:return_value_discarded
	gamestate.connect("dance_change", self, "_on_dance_change")
# warning-ignore:return_value_discarded
	gamestate.connect("game_end", self, "_on_game_end")
# warning-ignore:return_value_discarded
	gamestate.connect("pilfer", self, "_on_pilfer")
# warning-ignore:return_value_discarded
	gamestate.connect("write_log", logger, "_on_write_log")
# warning-ignore:return_value_discarded
	gamestate.connect("write_report", report_log, "_on_write_log")
# warning-ignore:return_value_discarded
	gamestate.connect("dance_ended", self, "_on_dance_end")
# warning-ignore:return_value_discarded
	gamestate.connect("dance_started", self, "_on_dance_start")
# warning-ignore:return_value_discarded
	gamestate.connect("connection_made", connection_graph, "add_spring")
# warning-ignore:return_value_discarded
	gamestate.connect("song_start", self, "_on_song_start")
# warning-ignore:return_value_discarded
	gamestate.connect("song_end", self, "_on_song_end")
# warning-ignore:return_value_discarded
	gamestate.connect("connection_broken", connection_graph, "remove_spring")
# warning-ignore:return_value_discarded
	gamestate.connect("begin_rest", self, "_on_begin_rest")
# warning-ignore:return_value_discarded
	gamestate.connect("end_rest", self, "_on_end_rest")
	view_connections.connect("mouse_entered", self , "_on_connection_hover")
	view_connections.connect("mouse_exited", self , "_on_connection_unhover")

	connection_graph.connect("npc_focus", self, "_focus_npc")
	connection_graph.connect("npc_unfocus", self, "_unfocus_npc")
	connection_graph.connect("npc_click", self, "_focus_npc", [true])
	ability_selector.connect("selector_click", self, "toggle_ability")
	done.connect("pressed", self, "_show_game_over_screen")

	dance_gauge.stages = [gamestate.dance_duration]
	rest_gauge.stages = [gamestate.rest_duration]

	report.connect("hide", self, "_report_done")

	randomize()
	patterns.shuffle()
	gamestate.init()
	for i in gamestate.npcs.size():
		var npc = gamestate.npcs[i]
		npc.connect("intel_level_up", self, "_on_intel_level_up")
		npc.connect("write_log", logger, "_on_write_log")
		npc.connect("faction_changed", self, "_on_npc_faction_change", [npc])
		npc.connect("scandal", self, "_on_scandal", [npc])
		var vertex = Vertex.instance()
		vertex.npc = npc
		connection_graph.add_child(vertex)
		vertex.visible = false

func _gui_input(event):
	if event.is_class("InputEventMouseButton"):
		var m: InputEventMouseButton = event
		if m.is_pressed():
			if m.button_index == BUTTON_LEFT:
				if npc_info.visible:
					_focus_npc(npc_info.npc, true)
			if m.button_index == BUTTON_RIGHT:
				if npc_info.visible:
					_unfocus_npc(true)

var sticky_npc: NPC = null
func _focus_npc(npc: NPC, sticky: bool = false):
	if sticky:
		sticky_npc = npc
	npc_info.npc = npc
	npc_info.visible = !!npc_info.npc
	npc_info.gamestate = gamestate
	npc_info.snap()

func _unfocus_npc(sticky: bool = false):
	if sticky:
		sticky_npc = null
	npc_info.npc = sticky_npc
	npc_info.visible = !!npc_info.npc
	npc_info.snap()

var connection_hover = false
func _on_connection_hover():
	connection_hover = true
	update_see_connection_panel()

func _on_connection_unhover():
	connection_hover = false
	update_see_connection_panel()

func update_see_connection_panel():
	connection_panel.visible = connection_hover || view_connections.pressed || faction_queue_wait > 0
	if gamestate.count_revealed_vertices() == 0:
		connection_panel.visible = false

var game_is_over: bool = false
func _on_game_end():
	game_is_over = true
	$done.visible = true

func _unhandled_input(event):
	if paused || game_is_over:
		return
	var moved = false
	var acted = false
	var dir: int = -1
	if event.is_action_pressed("left"):
		dir = Dir.DIR.LEFT
	elif event.is_action_pressed("right"):
		dir = Dir.DIR.RIGHT
	elif event.is_action_pressed("up"):
		dir = Dir.DIR.UP
	elif event.is_action_pressed("down"):
		dir = Dir.DIR.DOWN
	elif event.is_action_pressed("ability_1"):
		toggle_ability(Ability.TYPE.NONE)
	elif event.is_action_pressed("ability_2"):
		toggle_ability(Ability.TYPE.SHOVE)
	elif event.is_action_pressed("ability_3"):
		toggle_ability(Ability.TYPE.PILFER)
	if dir >= 0:
		moved = gamestate.try_move_player(dir)
		if !moved:
			var action = gamestate.try_player_action(dir)
			moved = action.moved
			acted = action.acted
	if moved:
		track_player_dances(dir)
	if moved || acted:
		gamestate.tick_round()
		if npc_info.visible:
			npc_info._refresh()

func toggle_ability(i):
	if gamestate.selected_ability == i:
		gamestate.selected_ability = 0
	else:
		gamestate.selected_ability = i
	ability_selector.selected = gamestate.selected_ability

const kick_intensity: float = 200.0
const default_wait: float = 0.1
const partner_offset: float = 11.0
func _on_character_moved(d: Dancer, kick_dir: int = Dir.NO_DIR, was_shove: bool = false):
	if d.id == GameState.player_id:
		flush_moves()
	var target_pos = dancer_screen_pos(d.pos)
	if d.has_partner():
		target_pos += Dir.dir_to_vec(d.partner_dir) * partner_offset
	var glyph = glyphs[d.id]
	var kick = kick_intensity * Dir.dir_to_vec(kick_dir)
	if was_shove:
		kick *= 5 # yeet
		sfx.play(sfx.SFX.SHOVE)
	move_queue_glyph.append(glyph)
	move_queue_pos.append(target_pos)
	move_queue_kick.append(kick)
	var wait = default_wait
	if d.has_partner() && !d.leading:
		wait = 0.05
	if kick_dir == Dir.NO_DIR:
		wait = 0
	if d.id == GameState.player_id:
		wait = 0
	move_queue_wait.append(wait)
	set_physics_process(true)

var move_queue_glyph: Array = []
var move_queue_pos: Array = []
var move_queue_kick: Array = []
var move_queue_wait: Array = []

func flush_moves():
	while move_queue_wait.size() > 0:
		advance_move_queue()

func advance_move_queue():
	var _w = move_queue_wait.pop_front()
	var kick = move_queue_kick.pop_front()
	var target_pos = move_queue_pos.pop_front()
	var glyph = move_queue_glyph.pop_front()
	glyph.position = target_pos
	glyph.kick(kick)

var paused = false
func _physics_process(delta):
	if paused: return
	var more = false
	if move_queue_wait.size() > 0:
		more = true
		move_queue_wait[0] -= delta
		if move_queue_wait[0] <= 0:
			advance_move_queue()
	if faction_queue_wait > 0:
		more = true
		faction_queue_wait -= delta
		if faction_queue_wait <= 0:
			advance_faction_queue()
		update_see_connection_panel()
	set_physics_process(more)

const grace_particle = preload("res://ui/grace_particle.tscn")
func _on_grace_changed(amount: int):
	if amount > grace.amount:
		var particle = grace_particle.instance()
		send_particle(glyphs[0],grace_guage,particle)
		sfx.play(sfx.SFX.GRACE)
	grace.amount = amount
	ability_selector.level = Core.grace_info(amount).level

func _on_dance_change(_dances):
	clear_player_dances()
	load_player_dances()

func _on_dance_tracking_start():
	clear_player_dances()
	load_player_dances()
	sfx.play(sfx.SFX.START_DANCE)

const particle_kick: float = 500.0
func send_particle(from: Node, to: Node, what: Node, kickmod = 1.0):
	var from_pos
	if from.is_class("Control"):
		from_pos = from.rect_global_position + from.rect_size / 2.0
	elif from.is_class("Node2D"):
		from_pos = from.global_position
	else:
		return
	var anch: Anchor = Anchor.new()
	anch.visible = false
	var tgt = to.get_node_or_null("target")
	if !tgt:
		to.add_child(anch)
	else:
		tgt.add_child(anch)
	anch.add_child(what)
	anch.rect_global_position = from_pos
	anch.visible = true
	anch.friction = 0.7
	anch.snap()
	if to.is_class("Control"):
		anch.rect_global_position = to.rect_global_position + to.rect_size / 2.0
	else:
		anch.rect_position = Vector2.ZERO
	var kickdir = Vector2(randi(), randi()) - Vector2(0.5,0.5)
	anch.kick(particle_kick * kickdir * kickmod)
	anch.autoremove = true


func clear_player_dances():
	for c in dance_match.get_children():
		c.queue_free()

const DanceCard = preload("res://ui/dance_card.tscn")
func load_player_dances():
	var player: Dancer = gamestate.player()
	for dance in player.dance_tracker:
		var dance_card = DanceCard.instance()
		dance_card.gamestate = gamestate
		dance_card.dance = dance.duplicate()
		dance_match.add_child(dance_card)
	dance_match.sort_children()
	dance_match.snap()

func track_player_dances(dir: int):
	for dance_card in dance_match.get_children():
		dance_card.step(dir)
	dance_match.sort_children()

func _on_dance_timer(t: int):
	dance_gauge.current = t
	rest_gauge.current = t
	dance_countdown.text = "{0}".format([t])

const tile_size = Vector2(48,48)
func dancer_screen_pos(game_coord: Vector2) -> Vector2:
	return game_coord * tile_size


const intel_particle = preload("res://ui/intel_particle.tscn")
func _on_intel_level_up(npc: NPC, discovery: int):
	var dancer: Dancer = null
	var ref: WeakRef = npc.dancer
	if ref:
		dancer = ref.get_ref()
	var particle_source = null
	if dancer:
		particle_source = glyphs[dancer.id]
	var particle_target = glyphs[0]
	if (discovery == NPC.INTEL.CONNECTIONS):
		connection_graph.get_child(npc.npc_id).visible = true
		connection_graph._refresh()
		connection_graph.update_visible_support()
		view_connections.visible = gamestate.count_revealed_vertices() >= 2
		particle_target = view_connections
	if (discovery == NPC.INTEL.FACTION):
		connection_graph.update_vertex(npc.npc_id)
		connection_graph.update_visible_support()
	if (discovery == NPC.INTEL.RESOLVE):
		connection_graph.update_vertex(npc.npc_id)
		connection_graph.update_visible_support()
	if !!particle_source && !!particle_target:
		send_particle(particle_source,particle_target,intel_particle.instance(), 0)
#	if (discovery == NPC.INTEL.SUPPORT):
#		connection_graph.update_vertex(npc.npc_id)
#		connection_graph.update_visible_support(gamestate)
	view_connections.visible = gamestate.count_revealed_vertices() >= 2

const pilfer_icon = preload("res://ui/pilfer_icon.tscn")
func _on_pilfer(pilfer_target: Dancer = null):
	sfx.play(sfx.SFX.PILFER)
	var item_id = gamestate.player().item_id
	inventory_text.text = gamestate.get_item_name(item_id)
	inventory.visible = item_id != Trinkets.NO_ITEM
	var target = glyphs[pilfer_target.id]
	if pilfer_target.item_id >= 0:
		send_particle(inventory_text, target, pilfer_icon.instance(), 0.5)
	if item_id >= 0:
		send_particle(target, inventory_text, pilfer_icon.instance(), 0.5)

var patterns: Array = ["A","E","J","L","O","Q","R","S","T","U","V","W","X","h","i","l","m","u","y"]
func _on_dance_start():
# warning-ignore:return_value_discarded
	gamestate.player().connect("start_dance_tracker", self, "_on_dance_tracking_start", [], CONNECT_DEFERRED)
	rest_gauge.visible = false
	dance_gauge.visible = true
	dance_gauge.current = gamestate.dance_duration

	for g in glyphs:
		g.queue_free()
	glyphs = []
	for d in gamestate.dancers:
		var g = Glyph.new()
		g.visible = false
		g.character = d.character
		g.color = UIConstants.gender_color(d.gender)
		if d.id == 0:
			g.color = UIConstants.player_color
		glyphs.append(g)
		g.position = dancer_screen_pos(d.pos)
		g.snap()
		g.visible = true
		g.connect("mouse_entered", self, "_focus_npc", [d.npc])
		g.connect("mouse_exited", self, "_unfocus_npc")
		dance_floor.add_child(g)
		dance_floor_background.pattern = patterns[gamestate.night]
		inventory.visible = false


func _on_dance_end():
	trigger_report()
	clear_player_dances()

func trigger_report():
	paused = true
	report.night = gamestate.night
	report.show_modal(true)

func _report_done():
	paused = false

func _on_song_start():
	sfx.start_song()

func _on_song_end():
	sfx.end_song()

var faction_queue = []
var faction_animated = false
var faction_queue_wait = 0
const faction_queue_wait_amt = 1
const faction_queue_wait_anim_amt = 1

func queue_faction_change(id):
	if !connection_graph.get_child(id).visible:
		return
	if faction_queue.size() == 0:
		faction_queue_wait = faction_queue_wait_amt
	faction_queue.append(id)
	set_physics_process(true)

const faction_particle = preload("res://ui/faction_particle.tscn")
func advance_faction_queue():
	if faction_queue.size() == 0:
		return
	var target = faction_queue[0]
	if faction_animated:
		faction_queue.pop_front()
		connection_graph.update_vertex(target)
		connection_graph.update_visible_support()
		sfx.play(sfx.SFX.CHANGE_FACTION)
		faction_queue_wait = faction_queue_wait_amt
		faction_animated = false
	else:
		var neighbors = connection_graph.visible_neighbors(target)
		for n in neighbors:
			if n.displayed_faction == NPC.SUPPORT:
				send_particle(n, connection_graph.get_child(target), faction_particle.instance(), 0)
		faction_queue_wait = faction_queue_wait_amt
		faction_animated = true

func _on_npc_faction_change(npc):
	queue_faction_change(npc.npc_id)

func _on_begin_rest():
	dance_gauge.visible = false
	dance_icon.visible = false
	rest_gauge.visible = true
	rest_icon.visible = true
	rest_gauge.current = gamestate.rest_duration

func _on_end_rest():
	dance_gauge.visible = true
	dance_icon.visible = true
	rest_gauge.visible = false
	rest_icon.visible = false
	dance_gauge.current = gamestate.rest_duration

func _show_game_over_screen():
	var epilogue = preload("res://epilogue.tscn").instance()
	epilogue.is_victory = gamestate.did_win()
	epilogue.is_scandal = gamestate.is_scandal
	var parent = get_parent()
	parent.remove_child(self)
	call_deferred("free")
	parent.add_child(epilogue)

var scandal_particle = preload("res://ui/scandal_particle.tscn")
func _on_scandal(npc):
	var dancer: Dancer = null
	var ref: WeakRef = npc.dancer
	if ref:
		dancer = ref.get_ref()
	var particle_source = null
	if dancer:
		particle_source = glyphs[dancer.id]
	glyphs[dancer.id].angry = true
	var particle_target = glyphs[0]
	send_particle(particle_source,particle_target,scandal_particle.instance(), 0)
