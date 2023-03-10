extends Control

var _target: WeakRef
var _dv: Vector2
var _spd: float = 10.0

const fading = true

func _init(target: Control, dv: Vector2 = Vector2(0,-1.0), spd: float = 500):
	rect_clip_content = true
	rect_size = target.rect_size
	rect_position = target.rect_position
	var parent = target.get_parent()
	parent.add_child_below_node(target, self)
	parent.remove_child(target)
	add_child(target)
	target.rect_position = Vector2(0,0)
	_target = weakref(target)
	_dv = dv
	_spd = spd

static func _overlap(l: Rect2, r: Rect2) -> Rect2:
	var topleft_x = max(l.position.x, r.position.x)
	var topleft_y = max(l.position.y, r.position.y)
	var bottomright_x = min(l.position.x + l.size.x, r.position.x + r.size.x)
	var bottomright_y = min(l.position.y + l.size.y, r.position.y + r.size.y)
	return Rect2(topleft_x, topleft_y, bottomright_x - topleft_x, bottomright_y - topleft_y)

func _process(delta):
	var t = _target.get_ref()
	if t == null:
		queue_free()
		return
	t.rect_position += delta * _dv * _spd
	var r = _overlap(t.get_rect(), Rect2(Vector2(0,0), rect_size))
	rect_position += r.position
	rect_size = r.size
	if r.size.x <= 0 || r.size.y <= 0:
		queue_free()
