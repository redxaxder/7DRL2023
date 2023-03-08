tool

extends Container

class_name Anchor

export var target_speed: float = 10.0
export var top_speed: float = 10.0
export var acceleration: float = 10.0
export var snap_dist: float = 5.0
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
	_last_pos = rect_global_position

func kick(v: Vector2):
	velocity += v
	set_process(true)

var _last_pos: Vector2 = Vector2.ZERO
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
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
		return
	var c = get_child(0)
	var target = -offset * target_speed
	velocity = velocity.move_toward(target, delta * acceleration)
	var skid = velocity - velocity.project(target)
	var unskid = min(skid_correction * delta,1.0) * -skid
	velocity += unskid 
	velocity = velocity.clamped(top_speed)
	if cos(velocity.angle_to(-offset)) < -0.5:
		velocity *= pow(0.5, delta)

	var prev_offset = offset
	offset += velocity * delta
	
	var overshoot = cos(offset.angle_to(prev_offset)) < -0.5
	var l: float = offset.length()
	if l <= snap_dist || is_nan(l) || overshoot:
		snap()
		set_process(false)
	c.rect_position = offset
