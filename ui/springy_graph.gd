tool
extends Control

#graph edges v.x <-> v.y
#v.x and v.y are indices of children
export var springs: PoolVector2Array setget set_springs
export var repulsion_constant: float = 0.5
export var attraction_constant: float = 0.5
export var friction: float = 0.2
export var static_friction: float = 10
export var max_velocity: float = 200

export var anchor: bool = true
export var anchor_attraction: float = 0.2

var _velocities: PoolVector2Array

func _ready():
	_refresh()

func set_springs(x):
	springs = x
	_refresh()

var _neighbors: Dictionary = {}
func _refresh():
	_velocities = PoolVector2Array()
	for c in get_children():
		_velocities.append(Vector2.ZERO)
	_neighbors = {}
	for s in springs:
		if _neighbors.has(s.x):
			_neighbors[int(s.x)].append(s.y)
		else:
			_neighbors[int(s.x)] = [s.y]
		if _neighbors.has(s.y):
			_neighbors[int(s.y)].append(s.x)
		else:
			_neighbors[int(s.y)] = [s.x]
	set_physics_process(true)

func _physics_process(delta):
	var n = get_child_count()
	var c = get_children()
	for i in range(n): # update velocities
		var me: Control = c[i]
		_velocities[i] *= pow(1.0 - friction, delta)
		for ix in _neighbors.get(i,[]): # attraction
			var neighbor: Control = c[ix]
			var v: Vector2 = neighbor.rect_position - me.rect_position
			var x = v.length()
			#attraction increases as distance increases
			var f = attraction_constant * x
			var v_unit = v / v.length()
			_velocities[i] += f * v_unit * delta
		for ix in range(n): # repulsion
			var neighbor: Control = c[ix]
			if ix == i: continue
			var v: Vector2 = neighbor.rect_position - me.rect_position
			while v.length() <= 0.1: #wiggle if too close
				me.rect_position += Vector2(randf() - 1,randf() - 1)
				v  =  neighbor.rect_position - me.rect_position
			var x = v.length()
			#repulsion increases as distance decreases
			var f = - (repulsion_constant * (1.0/x))
			var v_unit = v / x
			_velocities[i] += f * v_unit * delta
		if anchor: # attraction to anchor
			var v: Vector2 = rect_size / 2.0 - me.rect_position
			var x = v.length()
			var v_unit = v / v.length()
			var f = anchor_attraction * x
			_velocities[i] += (f * v_unit * delta).clamped(max_velocity)
	var moved = false
	for i in range(n): # apply velocities
		if _velocities[i].length() > static_friction:
			c[i].rect_position += _velocities[i]
			moved = true
		c[i].rect_position.x = min(rect_size.x - c[i].rect_size.x, c[i].rect_position.x)
		c[i].rect_position.y = min(rect_size.y - c[i].rect_size.y, c[i].rect_position.y)
		c[i].rect_position.x = max(0, c[i].rect_position.x)
		c[i].rect_position.y = max(0, c[i].rect_position.y)
	if !moved:
		set_physics_process(false)
	
