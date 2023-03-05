tool
extends GridContainer

export var pattern: String = "A" setget set_pattern

export var width: int = 10 setget set_width
export var height: int = 10 setget set_height

const Tile = preload("res://ui/floor_tile.tscn")

func _ready():
	_reload_tiles()

func set_width(i: int):
	width = i
	columns = i
	_reload_tiles()

func set_height(i: int):
	height = i
	_reload_tiles()

func _reload_tiles():
	self.columns = width
	for c in self.get_children():
		c.queue_free()
	for _x in range(width):
		for _y in range(height):
			var tile = Tile.instance()
			tile.set_pattern(pattern)
			add_child(tile)
			

func set_pattern(p: String):
	pattern = p
	for c in self.get_children():
		c.set_pattern(p)

