tool

extends Container

class_name Anchor

export var target_speed: float = 50.0
export var top_speed: float = 600.0
export var acceleration: float = 1600.0

export var friction: float = 0.0

export var autoremove: bool = false

export var snap_close: bool = true
export var snap_dist: float = 5.0
export var snap_overshoot: bool = true
export var skid_correction: float = 2.0

#export var momentum: Vector2 = Vector2(0,0)
export var offset: Vector2 = Vector2.ZERO
export var velocity: Vector2  = Vector2.ZERO

func _ready():
	set_notify_transform(true)
	snap()

func snap():
	offset = Vector2.ZERO
	velocity = Vector2.ZERO
	if is_visible_in_tree():
		_last_pos = rect_global_position

func kick(v: Vector2):
	velocity += v
	set_process(true)

var _last_pos: Vector2 = Vector2.ZERO
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if is_visible_in_tree():
			offset += _last_pos - rect_global_position
			_last_pos = rect_global_position
			queue_sort()
			set_process(true)

	if what == NOTIFICATION_SORT_CHILDREN:
		var i = get_child_count()
		if i != 1:
			return
		var c: Control = get_child(0)
		c.rect_size = rect_size
		rect_size = c.rect_size
		if offset != Vector2.ZERO:
			set_process(true)

func _process(delta):
	var i = get_child_count()
	if i != 1:
		set_process(false)
		_stop()
		return
	var c = get_child(0)
	var target = -offset * target_speed
	velocity = velocity.move_toward(target, delta * acceleration)
	var skid = velocity - velocity.project(target)
	var unskid = min(skid_correction * delta,1.0) * -skid
	velocity += unskid 
	velocity *= pow(1.0 - friction, delta)
	velocity = velocity.clamped(top_speed)
	if cos(velocity.angle_to(-offset)) < -0.5:
		velocity *= pow(0.5, delta)

	var prev_offset = offset
	offset += velocity * delta
	
	var l: float = offset.length()
	var do_snap = false
	if snap_close && offset.length() < snap_dist:
		do_snap = true
	if snap_overshoot && cos(offset.angle_to(prev_offset)) < -0.5:
		do_snap = true
	if do_snap || is_nan(l):
		snap()
	c.rect_position = offset
	if (velocity.abs() + offset.abs()).length_squared() < 0.1:
		_stop()
	
func _stop():
		set_process(false)
		if autoremove:
			queue_free()
