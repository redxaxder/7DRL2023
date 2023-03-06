extends Node2D

var gamestate: GameState = GameState.new()

const Dirstring = preload("res://ui/dirstring.tscn")
const HDirstring = preload("res://ui/highlighted_dirstring.tscn")

onready var dance_floor = $dance/dance_floor
onready var player_history = $step_history
onready var dance_countdown = $dance_countdown
onready var current_dances = $current_dances
onready var dance_match = $dance_match
onready var grace_guage = $grace/grace_guage
onready var grace_level = $grace/grace_level

var glyphs: Array = []

func _ready():
	gamestate.add_dancer(Dancer.new()) # player
# warning-ignore:return_value_discarded
	gamestate.connect("character_moved", self, "_on_character_moved")
	gamestate.connect("grace", self, "_on_grace_changed")
	gamestate.connect("dance_time", self, "_on_dance_timer")
	gamestate.connect("dance_change", self, "_on_dance_change")
	for d in gamestate.dancers:
		var g = get_dancer_glyph(d)
		glyphs.append(g)
		dance_floor.add_child(g)
	set_current_dances(gamestate.current_dances)
	update_match()

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
	

func _on_character_moved(moved_to: Vector2, character: Dancer):
	glyphs[character.id].position = dancer_screen_pos(moved_to)
	if character.id == gamestate.player_id:
		player_history.steps = character.recent_moves
		update_match()

func _on_grace_changed(amount: int):
	grace_guage.current = amount
	grace_level.current = Core.grace_info(amount).level

func _on_dance_change(dances):
	set_current_dances(dances)

func _on_dance_timer(t: int):
	dance_countdown.text = "{0}".format([t])

const tile_size = Vector2(48,48)
func dancer_screen_pos(game_coord: Vector2) -> Vector2:
	return game_coord * tile_size

func get_dancer_glyph(_d: Dancer) -> Glyph:
	#TODO: different dancers look different
	var g = Glyph.new()
	g.character = "R"
	return g

var dance_orbit: Array = []
func set_current_dances(dances: Array):
	dance_orbit = []
	for c in current_dances.get_children():
		c.queue_free()
	for c in dance_match.get_children():
		c.queue_free()
	for dance in dances:
		var dirstring = Dirstring.instance()
		dirstring.steps = Array(dance)
		current_dances.add_child(dirstring)
		var orbit = D8.orbit(dance)
		for g in orbit.size():
			var steps = orbit[g]
			var hds = HDirstring.instance()
			hds.steps = Array(steps)
			hds.sortkey1 = dance
			hds.sortkey2 = g
			dance_match.add_child(hds)

func update_match():
	for c in dance_match.get_children():
		c.progress = Core.steps_completed(player_history.steps, c.steps)
		if c.progress == 4:
			c.progress = 0
	var children = dance_match.get_children()
	children.sort_custom(self,"custom_sort_matches")
	for i in children.size():
		dance_match.move_child(children[i], i)

func custom_sort_matches(l: Node, r: Node) -> bool:
	if l.progress > r.progress:
		return true
	elif r.progress > l.progress:
		return false
	if l.sortkey1 > r.sortkey1:
		return true
	elif r.sortkey1 > l.sortkey1:
		return false
	return l.sortkey2 > r.sortkey2
	
