extends Control

export var is_scandal: bool setget set_scandal
export var is_victory: bool setget set_victory

onready var epilogue = $epilogue/Label
onready var victory = $victory_text
onready var defeat = $defeat_text
onready var space = $initial_space
onready var scandal = $scandal_text
onready var victory_box = $victory_box
onready var defeat_box = $defeat_box

func set_scandal(x):
	is_scandal = x
	_refresh()

func set_victory(x):
	is_victory = x
	_refresh()

func _ready():
	sfx.start_song(0)
	_refresh()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		sfx.end_song()
# warning-ignore:return_value_discarded
		sfx.connect("song_ended",self, "_transition", [],CONNECT_ONESHOT | CONNECT_DEFERRED)

func _refresh():
	if !epilogue: return
	epilogue.text = space.text
	if is_scandal:
		epilogue.text += scandal.text
	if is_victory:
		epilogue.text += victory.text
	else:
		epilogue.text += defeat.text
	victory_box.visible = is_victory
	defeat_box.visible = !is_victory

func _transition():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://testbed.tscn")
