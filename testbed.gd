extends Node2D

export var gamestate: Resource = Core.new_game()

onready var dance_floor = $Control/dance_floor
var glyphs: Array = []

func _ready():
	gamestate.connect("character_moved", self, "_on_character_moved")
	for d in gamestate.dancers:
		var g = get_dancer_glyph(d)
		glyphs.append(g)
		dance_floor.add_child(g)

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

const tile_size = Vector2(32,32)
func dancer_screen_pos(game_coord: Vector2) -> Vector2:
	return game_coord * tile_size

func get_dancer_glyph(d: Dancer) -> Glyph:
	var g = Glyph.new()
	g.index = 13
	return g
