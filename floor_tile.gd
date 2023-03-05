tool
extends Control

var pattern: String setget set_pattern

func _ready():
	if $HBoxContainer/Label:
		$HBoxContainer/Label.text = pattern
	else:
		print("aaa")

func set_pattern(s: String):
	pattern = s
	if $HBoxContainer/Label:
		$HBoxContainer/Label.text = pattern
