extends Node

export var music_on: bool = true setget set_music_on

signal music_toggled

func set_music_on(x):
	music_on = x
	emit_signal("music_toggled")
