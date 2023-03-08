extends Control

var gamestate: GameState = GameState.new()


onready var dance_floor = $dance/MarginContainer/Control/dance_floor
onready var dance_countdown = $dance_countdown
onready var dance_match = $dance_match
onready var grace = $grace
onready var npc_info = $npc_info
onready var connection_panel = $PanelContainer
onready var connection_graph = $PanelContainer/springy_graph
onready var view_connections = $view_connections
onready var sfx = $sfx

var glyphs: Array = []
var npcs: Array = []

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

	view_connections.connect("mouse_entered", self , "_on_connection_hover")
	view_connections.connect("mouse_exited", self , "_on_connection_unhover")

	var player = Dancer.new()
	player.pos = gamestate.get_free_space()
	gamestate.add_dancer(player)
	player.connect("start_dance_tracker", self, "_on_dance_tracking_start", [], CONNECT_DEFERRED)
	var letters = ["A","B","W","X","Y","Z","D","E","F","S","T"]
	var n = letters.size()
	for i in range(n):
		var npc = NPC.new()
		npc.letter = letters[i]
		npc.npc_id = i
		npc.gender = (i % 2) ^ 1
		npc.connect("intel_level_up", self, "_on_intel_level_up")

		var vertex = Vertex.instance()
		vertex.npc = npc
		connection_graph.add_child(vertex)
		vertex.visible = false

		npc.connections = []
		for j in range(i):
			if randi() % 3 == 0:
				npc.connections.append(j)
				npcs[j].connections.append(i)
				connection_graph.add_spring(i,j)

		npcs.append(npc) # TODO: gamestate should shepard the NPCs

		var dancer = Dancer.new()
		dancer.npc = npc
		dancer.pos = gamestate.get_free_space()
		dancer.character = npc.letter
		dancer.gender = npc.gender
		gamestate.add_dancer(dancer)

	for d in gamestate.dancers:
		var g = Glyph.new()
		g.visible = false
		g.character = d.character
		g.modulate = UIConstants.gender_color(d.gender)
		glyphs.append(g)
		g.position = dancer_screen_pos(d.pos)
		g.snap()
		g.visible = true
		g.connect("mouse_entered", self, "_on_dancer_hover", [d])
		g.connect("mouse_exited", self, "_on_dancer_unhover")
		dance_floor.add_child(g)

	gamestate.tick_round()

var sticky_dancer: Dancer = null
func _gui_input(event):
	if event.is_class("InputEventMouseButton"):
		var m: InputEventMouseButton = event
		if m.is_pressed():
			if m.button_index == BUTTON_LEFT:
				if npc_info.visible:
					sticky_dancer = npc_info.dancer
			if m.button_index == BUTTON_RIGHT:
				if npc_info.visible:
					npc_info.visible = false
					sticky_dancer = null
func _on_dancer_hover(d: Dancer):
	npc_info.dancer = d
	npc_info.visible = true
	npc_info.snap()


func _on_dancer_unhover():
	npc_info.visible = false
	if sticky_dancer:
		npc_info.dancer = sticky_dancer
		npc_info.visible = true
		npc_info.snap()

func _on_connection_hover():
	connection_panel.visible = true
func _on_connection_unhover():
	connection_panel.visible = false || view_connections.pressed

func _on_game_end():
	get_tree().quit()

func _unhandled_input(event):
	var moved = false
	var dir: int = -1
	if event.is_action_pressed("left"):
		dir = Dir.DIR.LEFT
	elif event.is_action_pressed("right"):
		dir = Dir.DIR.RIGHT
	elif event.is_action_pressed("up"):
		dir = Dir.DIR.UP
	elif event.is_action_pressed("down"):
		dir = Dir.DIR.DOWN

	if dir >= 0:
		moved = gamestate.try_move_player(dir)
	if moved:
		gamestate.tick_round()
		track_player_dances(dir)
		if npc_info.visible:
			npc_info._refresh()

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
		var from = glyphs[0].global_position
		var to = grace.rect_global_position + grace.rect_size / 2
		send_particle(from,to,particle)
		sfx.play(sfx.SFX.GRACE)
	grace.amount = amount

func _on_dance_change(_dances):
	clear_player_dances()
	load_player_dances()

func _on_dance_tracking_start():
	clear_player_dances()
	load_player_dances()


const particle_kick: float = 500.0
func send_particle(from: Vector2, to: Vector2, what: Node):
	var anch: Anchor = Anchor.new()
	anch.visible = false
	add_child(anch)
	anch.add_child(what)
	anch.rect_global_position = from
	anch.visible = true
	anch.friction = 0.3
	anch.snap()
	anch.rect_global_position = to
	var kickdir = Vector2(randi(), randi()) - Vector2(0.5,0.5)
	anch.kick(particle_kick * kickdir)
	anch.autoremove = true


func clear_player_dances():
	for c in dance_match.get_children():
		c.queue_free()

const DanceCard = preload("res://ui/dance_card.tscn")
func load_player_dances():
	var player: Dancer = gamestate.dancers[0]
	for dance in player.dance_tracker:
		var dance_card = DanceCard.instance()
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

