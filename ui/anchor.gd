tool

extends Container

class_name Anchor

export var speed: float = 50.0

#export var momentum: Vector2 = Vector2(0,0)
var offset: Vector2 = Vector2(20,20)

func _ready():
	set_notify_transform(true)

var _last_pos: Vector2 = rect_position
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		offset += _last_pos - rect_position
		_last_pos = rect_position
		queue_sort()

	if what == NOTIFICATION_SORT_CHILDREN:
		var i = get_child_count()
		if i != 1:
			return
		var c: Control = get_child(0)
		rect_min_size = c.rect_min_size
		c.rect_size = rect_size
		if offset != Vector2.ZERO:
			set_process(true)

func _process(delta):
	var i = get_child_count()
	if i != 1:
		set_process(false)
		return
	var c = get_child(0)
	var target_dir = offset / offset.length()
	offset = offset.move_toward(Vector2.ZERO, delta * speed)
	c.rect_position = offset
