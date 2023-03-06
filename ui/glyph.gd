tool

extends Sprite

class_name Glyph


const cell_width: int = 32
const cell_height: int = 32
const cell_size: Vector2 = Vector2(cell_width,cell_height)
const shift: Vector2 = Vector2(0,-3)

export var character: String = "A" setget set_character

const font: DynamicFont = preload("res://ui/glyph.tres")

var _label: Label = null

func _ready():
	centered = false
	_refresh()

func set_character(x):
	character = x
	_refresh()

func _refresh():
	if !_label:
		_label = Label.new()
		_label.add_font_override("font", font)
		add_child(_label)
		_label.align = _label.ALIGN_CENTER
		_label.rect_position = shift
	_label.text = character
	
	if Engine.editor_hint: # the script is running in the editor!
		property_list_changed_notify()
