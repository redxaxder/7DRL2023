extends Control

func _ready():
	sfx.start_song(0)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):	
		sfx.end_song()
# warning-ignore:return_value_discarded
		if !sfx.is_connected("song_ended", self, "_transition"):
			sfx.connect("song_ended",self, "_transition", [],CONNECT_ONESHOT | CONNECT_DEFERRED)

func _transition():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://testbed.tscn")
