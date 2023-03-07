tool
extends Control

export var color: Color setget set_color
export var border_color: Color setget set_border_color
export var width: float = 1 setget set_width
export var current: int = 0 setget set_current
export var display_move_speed: float = 100
export  (Array, int) var stages = [100]

var _displayed: float = 0
var _amount: float = 0
var _next: float = 0

onready var meter = $meter

func _ready():
	snap()

func snap():
	_displayed = current
	
func set_width(w):
	width = w
	update()

func set_border_color(c):
	border_color = c
	update()

func set_color(c):
	color = c
	update()

func set_current(x: int):
	current = x
	_refresh()
	set_process(true)


func _refresh():
	_amount = _displayed
	_next = 100
	var stage = 0
	if stages.size() > 0:
		_next = stages[0]
	while _amount > _next && _next > 0:
		_amount -= _next
		stage += 1
		if stage >= stages.size():
			stage -= 1
		_next = stages[stage]

	if meter != null:
		meter.text = "{0} / {1}".format([int(_amount), int(_next)])
	update()



func _process(delta):
	var target = current
	var error: float = target - _displayed
	if abs(error) < delta * display_move_speed:
		_displayed = target
		set_process(false)
	else:
		_displayed += sign(error) * delta * display_move_speed
	_refresh()

func _draw():
	var rect: Rect2 = get_rect()
	var proportion: float = 0
	if _next > 0:
		proportion = _amount / _next
	if proportion > 1:
		proportion = 1
	var d = Vector2(1,1)
	var outer: Rect2 = Rect2(width*d / 2, rect_size - (width * d))
	draw_rect(outer, border_color, false, width, true)
	var inner: Rect2 = Rect2(width*d * 2, rect.size - (width * d * 4))
	inner.size.x *= proportion
	draw_rect(inner, color)
	
	
	
	
