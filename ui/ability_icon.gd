extends MarginContainer

export (int, "grace", "pilfer") var type: int setget set_type
export var action_dir: Vector2 setget set_dir

func set_type(x):
	type = x
	_refresh()

func set_dir(x):
	action_dir = x
	_refresh()

func _ready():
	_refresh()


onready var pilfer = $pilfer
onready var star = $star

#const pilver_table: Dictionary = { Vector2(1,1): 8, Vector2(1,-1): 2, Vector2(-1,1): 6, Vector2(-1,-1): 8}
func _refresh():
	for c in get_children():
		c.visible = false
	match type:
		Dance.TYPE.GRACE:
			if !star: return
			star.visible = true
		Dance.TYPE.PILFER:
			if !pilfer: return
			pilfer.visible = true
			var grid = $pilfer/pilfer
			for c in grid.get_children():
				c.modulate.a = 0
			match action_dir:
				#note: y axispoints down
				Vector2(1,1): # down-right
					grid.get_child(8).modulate = Color(1,1,1,1)
				Vector2(1,-1): # up right
					grid.get_child(2).modulate = Color(1,1,1,1)
				Vector2(-1,1): # down left
					grid.get_child(6).modulate = Color(1,1,1,1)
				Vector2(-1,-1): # up left
					grid.get_child(0).modulate = Color(1,1,1,1)
#
#
#
#
