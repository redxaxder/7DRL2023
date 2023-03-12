extends Control

func _ready():
	sfx.start_song(0)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		sfx.end_song()
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://testbed.tscn")
