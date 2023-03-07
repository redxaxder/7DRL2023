extends Node2D

var gamestate: GameState = GameState.new()


onready var dance_floor = $dance/dance_floor
onready var player_history = $step_history
onready var dance_countdown = $dance_countdown
onready var dance_match = $dance_match
onready var grace_guage = $grace/grace_guage
onready var grace_level = $grace/grace_level
onready var npc_info = $npc_info

var glyphs: Array = []

func _ready():
# warning-ignore:return_value_discarded
	gamestate.connect("character_moved", self, "_on_character_moved", [], CONNECT_DEFERRED)
# warning-ignore:return_value_discarded
	gamestate.connect("grace", self, "_on_grace_changed")
# warning-ignore:return_value_discarded
	gamestate.connect("dance_time", self, "_on_dance_timer")
# warning-ignore:return_value_discarded
	gamestate.connect("dance_change", self, "_on_dance_change")

	gamestate.add_dancer(Dancer.new()) # player
	var letters = ["A","B","W","X","Y","Z","D","E","F","S","T"]
	for i in letters.size():
		var dancer = Dancer.new()
		dancer.pos = gamestate.get_free_space()
		dancer.character = letters[i]
		dancer.gender = (i % 2) ^ 1
		gamestate.add_dancer(dancer)


	for d in gamestate.dancers:
		var g = get_dancer_glyph(d)
		g.modulate = UIConstants.gender_color(d.gender)
		glyphs.append(g)
		g.connect("mouse_entered", self, "_on_dancer_hover", [d])
		g.connect("mouse_exited", self, "_on_dancer_unhover")
		dance_floor.add_child(g)

	gamestate.tick_round()

func _on_dancer_hover(d: Dancer):
	npc_info.dancer = d
	npc_info.visible = true

func _on_dancer_unhover():
	npc_info.visible = false

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

func _on_character_moved(moved_to: Vector2, character: Dancer):
	glyphs[character.id].position = dancer_screen_pos(moved_to)

func _on_grace_changed(amount: int):
	grace_guage.current = amount
	grace_level.current = Core.grace_info(amount).level

func _on_dance_change(_dances):
	clear_player_dances()
	load_player_dances()

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

func get_dancer_glyph(d: Dancer) -> Glyph:
	var g = Glyph.new()
	g.character = d.character
	return g
