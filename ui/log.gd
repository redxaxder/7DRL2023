tool
extends PanelContainer

class_name Log

onready var bubbler = $BubblyLog

export var left_margin: int = 5

func _on_write_log(log_text: String):
	var new_entry = Label.new()
	new_entry.rect_size.x = rect_size.x
	new_entry.autowrap = true
	new_entry.visible = true
	new_entry.text = log_text
	new_entry.rect_position = Vector2(left_margin, -15)
	bubbler.spawn(new_entry)
