extends Control

var gamestate: GameState = GameState.new()


onready var dance_floor = $dance/MarginContainer/Control/dance_floor
onready var dance_countdown = $dance_countdown
onready var dance_match = $dance_match
onready var grace = $grace
onready var grace_guage = $grace/grace_guage
onready var npc_info = $npc_info
onready var connection_panel = $PanelContainer
onready var connection_graph = $PanelContainer/springy_graph
onready var view_connections = $view_connections
onready var sfx = $sfx
onready var inventory = $inventory
onready var inventory_text = $inventory/Label
onready var ability_selector = $ability_selector
onready var logger = $log

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
	gamestate.connect("write_log", logger, "_on_write_log")

	view_connections.connect("mouse_entered", self , "_on_connection_hover")
	view_connections.connect("mouse_exited", self , "_on_connection_unhover")
	
	connection_graph.connect("npc_focus", self, "_focus_npc")
	connection_graph.connect("npc_unfocus", self, "_unfocus_npc")
	connection_graph.connect("npc_click", self, "_focus_npc", [true])

	var player = Dancer.new()
	randomize()
	player.pos = gamestate.get_free_space()
	gamestate.add_dancer(player)
	player.connect("start_dance_tracker", self, "_on_dance_tracking_start", [], CONNECT_DEFERRED)
	var letters = ["A","B","W","X","Y","Z","D","E","F","S","T"]
	var n = letters.size()
	for i in range(n):
		var npc = gamestate.make_npc(i)
		npc.connect("intel_level_up", self, "_on_intel_level_up")
		var vertex = Vertex.instance()
		vertex.npc = npc
		connection_graph.add_child(vertex)
		vertex.visible = false
		#TODO: connect npcs based on history rather than randomly
		for j in range(i):
			if randi() % 3 == 0:
				npc.connections.append(j)
				gamestate.npcs[j].connections.append(i)
				connection_graph.add_spring(i,j)

	for attendee in gamestate.throw_a_party(7):
		var dancer = Dancer.new()
		dancer.npc = attendee
		attendee.dancer = weakref(dancer)
		dancer.pos = gamestate.get_free_space()
		dancer.character = attendee.letter
		dancer.gender = attendee.gender
		gamestate.add_dancer(dancer)
		if randi() % 5 <= 2:
			dancer.item_id = dancer.id

	for d in gamestate.dancers:
		var g = Glyph.new()
		g.visible = false
		g.character = d.character
		g.modulate = UIConstants.gender_color(d.gender)
		glyphs.append(g)
		g.position = dancer_screen_pos(d.pos)
		g.snap()
		g.visible = true
		g.connect("mouse_entered", self, "_focus_npc", [d.npc])
		g.connect("mouse_exited", self, "_unfocus_npc")
		dance_floor.add_child(g)

	gamestate.tick_round()

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
	npc_info.snap()

func _unfocus_npc(sticky: bool = false):
	if sticky:
		sticky_npc = null
	npc_info.npc = sticky_npc
	npc_info.visible = !!npc_info.npc
	npc_info.snap()

func _on_connection_hover():
	connection_panel.visible = true
func _on_connection_unhover():
	connection_panel.visible = false || view_connections.pressed

func _on_game_end():
	get_tree().quit()

func _unhandled_input(event):
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

func _physics_process(delta):
	if move_queue_wait.size() == 0:
		set_physics_process(false)
		return
	move_queue_wait[0] -= delta
	if move_queue_wait[0] <= 0:
		advance_move_queue()

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
	to.add_child(anch)
	anch.add_child(what)
	anch.rect_global_position = from_pos
	anch.visible = true
	anch.friction = 0.7
	anch.snap()
	if to.is_class("Control"):
		anch.rect_position = to.rect_size / 2.0
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
	var player: Dancer = gamestate.dancers[0]
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
	dance_countdown.text = "{0}".format([t])

const tile_size = Vector2(48,48)
func dancer_screen_pos(game_coord: Vector2) -> Vector2:
	return game_coord * tile_size

func _on_intel_level_up(npc: NPC, discovery: int):
	if (discovery == NPC.INTEL.CONNECTIONS):
		connection_graph.get_child(npc.npc_id).visible = true
		connection_graph._refresh()

const pilfer_icon = preload("res://ui/pilfer_icon.tscn")
func _on_pilfer(pilfer_target: Dancer = null):
	sfx.play(sfx.SFX.PILFER)
	var item_id = gamestate.dancers[GameState.player_id].item_id
	inventory_text.text = gamestate.get_item_name(item_id)
	inventory.visible = item_id != Trinkets.NO_ITEM
	var target = glyphs[pilfer_target.id]
	if pilfer_target.item_id >= 0:
		send_particle(inventory_text, target, pilfer_icon.instance(), 0.5)
	if item_id >= 0:
		send_particle(target, inventory_text, pilfer_icon.instance(), 0.5)
