extends Node2D

var gamestate: GameState = Core.new_game()

const Dirstring = preload("res://ui/dirstring.tscn")

onready var dance_floor = $dance/dance_floor
onready var player_history = $step_history
onready var current_dances = $current_dances
var glyphs: Array = []

func _ready():
# warning-ignore:return_value_discarded
	gamestate.connect("character_moved", self, "_on_character_moved")
	for d in gamestate.dancers:
		var g = get_dancer_glyph(d)
		glyphs.append(g)
		dance_floor.add_child(g)
	set_current_dances(gamestate.current_dances)

func _unhandled_input(event):
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
		gamestate.try_move_player(dir)
	
	

func _on_character_moved(moved_to: Vector2, character: Dancer):
	glyphs[character.id].position = dancer_screen_pos(moved_to)
	if character.id == gamestate.player_id:
		$step_history.steps = character.recent_moves

const tile_size = Vector2(32,32)
func dancer_screen_pos(game_coord: Vector2) -> Vector2:
	return game_coord * tile_size

func get_dancer_glyph(_d: Dancer) -> Glyph:
	#TODO: different dancers look different
	var g = Glyph.new()
	g.index = 13
	return g

func set_current_dances(dances: Array):
	for c in current_dances.get_children():
		c.queue_free()
	for dance in dances:
		var orbit = D8.orbit(dance)
		for steps in orbit:
			var dirstring = Dirstring.instance()
			dirstring.steps = Array(steps)
			print(Core.steps_to_string(steps))
			current_dances.add_child(dirstring)
