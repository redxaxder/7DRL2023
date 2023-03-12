tool
extends Control


export var img: Texture = null setget set_img

onready var panel = $control/Panel

func set_img(x):
	img = x
	_refresh()

func _ready():
	_refresh()

func _refresh():
	if !panel: return
	var sb = StyleBoxEmpty.new()
	if img:
		sb = StyleBoxTexture.new()
		sb.texture = img
	panel.add_stylebox_override("panel", sb)
