tool

extends Sprite

class_name Glyph


const cell_width: int = 32
const cell_height: int = 32
const cell_size: Vector2 = Vector2(cell_width,cell_height)
const shift: Vector2 = Vector2(0,-3)

export var character: String = "A" setget set_character
export var color: Color = Color(1,1,1) setget set_color

const font: DynamicFont = preload("res://ui/glyph.tres")

var _anchor: Anchor = null
var _label: Label = null

# warning-ignore:unused_signal
signal mouse_entered
# warning-ignore:unused_signal
signal mouse_exited

func _ready():
	centered = false
	_refresh()
	snap()

func set_character(x):
	character = x
	_refresh()

func set_color(x):
	color = x
	_refresh()

func kick(v: Vector2):
	if _anchor:
		_anchor.kick(v)

func snap():
	_anchor.snap()

func _refresh():
	if !_anchor:
		_anchor = Anchor.new()
		_anchor.acceleration = 1600
		_anchor.target_speed = 50
		_anchor.top_speed = 800
		_anchor.skid_correction = 5
		_anchor.friction = 0.999
		_anchor.snap_close = false
		_anchor.snap_overshoot = false
		_anchor.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(_anchor)
	if !_label:
		_label = Label.new()
		_label.mouse_filter = Control.MOUSE_FILTER_PASS
# warning-ignore:return_value_discarded
		_label.connect("mouse_entered", self, "emit_signal", ["mouse_entered"])
# warning-ignore:return_value_discarded
		_label.connect("mouse_exited", self, "emit_signal", ["mouse_exited"])
		_label.add_font_override("font", font)
		_label.align = _label.ALIGN_CENTER
		_label.rect_position = shift
		_anchor.add_child(_label)
	_label.text = character
	_label.self_modulate = color
	
	if Engine.editor_hint: # the script is running in the editor!
		property_list_changed_notify()
