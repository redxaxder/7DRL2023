extends Control


export (float,0,1000) var progress:float = 0.0 setget set_progress
export var speed:float = 1.0

onready var label = $Label

func set_progress(x):
	progress = x
	_refresh()

func _ready():
	progress = 0
	set_process(true)
	_refresh()

func _process(delta):
	self.progress += delta * speed
	
func _refresh():
	if label:
		label.rect_position.y = -progress
