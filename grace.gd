tool
extends HBoxContainer

onready var stars = $stars
onready var guage = $grace_guage

export var amount: float setget set_amount

func set_amount(x):
	amount = x
	_refresh()

func _ready():
	_refresh()

func _refresh():
	guage.stages = Core.grace_stages
	var info = Core.grace_info(amount)
	stars.count = info.level
	guage.current = amount
