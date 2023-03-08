tool
extends Control

class_name TickMark

export (float,0,1) var percentage: float = 0 setget set_percentage
export var color: Color setget set_color
export var width: float = 1.0 setget set_width
export var extension: float = 0.0 setget set_extension

func set_percentage(x):
	percentage = x
	update()

func set_color(x):
	color = x
	update()

func set_width(x):
	width = x
	update()

func set_extension(x):
	extension = x
	update()

func _draw():
	var x = rect_size.x * percentage
	draw_line(Vector2(x,-extension),Vector2(x,rect_size.y+extension),color,width, true)
