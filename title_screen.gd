extends Node2D

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene("res://testbed.tscn")
