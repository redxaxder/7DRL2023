extends Control

func _ready():
	sfx.start_song(0)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
# warning-ignore:return_value_discarded
		sfx.end_song(true)
		get_tree().change_scene("res://testbed.tscn")
