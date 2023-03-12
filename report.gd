extends Control

export var night: int = 1 setget set_night

onready var title = $vboxcontainer/title
onready var accept = $vboxcontainer/accept

onready var rlog = $log

func set_night(x):
	night = x
	_refresh()

func _ready():
	if accept:
		accept.connect("pressed", self, "hide")
	_refresh()

const nights = ["One", "Two", "Three", "Four", "Five", "Six", "Seven"]
func _refresh():
	if title:
		title.text = "Night {0} Complete".format([nights[night-1]])
