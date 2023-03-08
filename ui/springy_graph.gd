extends Control

#graph edges v.x <-> v.y
#v.x and v.y are indices of children
export var springs: PoolVector2Array setget set_springs
export var repulsion_constant: float = 0.5
export var attraction_constant: float = 0.5
export var friction: float = 0.2
export var static_friction: float = 10
export var max_velocity: float = 200

export var has_anchor: bool = true setget set_has_anchor
export var anchor_attraction: float = 0.2

export var edge_gap: float = 50
export var edge_width: float = 2.0
export var edge_color: Color = Color(1,1,1)



var _velocities: PoolVector2Array

func _ready():
	for c in self.get_children():
		c.connect("item_rect_changed", self, "_refresh")
	_refresh()

func add_child(node: Node, legible_unique_name: bool = false):
# warning-ignore:return_value_discarded
	node.connect("item_rect_changed", self, "_refresh")
	.add_child(node, legible_unique_name)
	_refresh()

func set_springs(x):
	springs = x
	_refresh()

func set_has_anchor(x):
	has_anchor = x
	_refresh()

func clear_springs():
	springs = PoolVector2Array()
	_refresh()

func add_spring(i: int, j: int):
	if i == j: return
	var v = Vector2(min(i,j),max(i,j))
	for s in springs:
		if s == v:
			return
	springs.append(v)
	_refresh()

func remove_spring(i: int, j: int):
	var v = Vector2(min(i,j),max(i,j))
	var new_springs = PoolVector2Array()
	for s in springs:
		if v != s:
			new_springs.append(s)
	springs = new_springs
	_refresh()

func _refresh():
	if _velocities.size() != get_child_count():
		_velocities = PoolVector2Array()
		for c in get_children():
			_velocities.append(Vector2.ZERO)
	set_physics_process(true)

func _draw():
	var n = get_child_count()
	if n == 0:
		return
	var c = get_children()
	for s in springs:
		if s.x >= c.size() or s.y >= c.size():
			continue
		if !c[s.x].visible || !c[s.y].visible: continue
		var v0: Vector2 = c[s.x].rect_position + c[s.x].rect_size / 2.0
		var v1: Vector2 = c[s.y].rect_position + c[s.y].rect_size / 2.0
		var edge_start = v0.move_toward(v1,edge_gap)
		var edge_end = v1.move_toward(v0, edge_gap)
		draw_line(edge_start,edge_end,edge_color, edge_width, true)

func _physics_process(delta):
	var n = get_child_count()
	if n == 0:
		return
	var c = get_children()

	for s in springs: # attraction
		var i = int(s.x)
		var j = int(s.y)
		if !c[i].visible || !c[j].visible: continue
		if i >= c.size() or j >= c.size():
			continue
		var v: Vector2 = c[i].rect_position - c[j].rect_position
		var x = v.length()
		if x > 0.1:
			var f = attraction_constant * x / 1000.0
			var dv = - delta * f * v / x
			_velocities[i] += dv
			_velocities[j] -= dv

	for i in range(n):
		for j in range(0,i): # repulsion
			if !c[i].visible || !c[j].visible: continue
			var v: Vector2 = c[j].rect_position - c[i].rect_position
			while v.length() <= 0.1: #wiggle if too close
				c[i].rect_position += Vector2(randf() - 1,randf() - 1)
				v  =   c[j].rect_position - c[i].rect_position
			var x = v.length()
			var f = - repulsion_constant * 100.0/(x*x)
			var dv = delta * f * v / x
			_velocities[i] += dv
			_velocities[j] -= dv
		if has_anchor: # attraction to anchor
			var v: Vector2 = rect_size / 2.0 - c[i].rect_position
			var x = v.length()
			var f = anchor_attraction * x
			var dv = delta * f * v / x
			_velocities[i] += dv

	for i in range(n): # friction & clamp
		_velocities[i] *= pow(1.0 - friction, delta)
		_velocities[i] = _velocities[i].clamped(max_velocity)

	var moved = false
	for i in range(n): # apply velocities
		if _velocities[i].length() > static_friction:
			c[i].rect_position += _velocities[i]
			moved = true
		else:
			_velocities[i] = Vector2.ZERO
		c[i].rect_position.x = min(rect_size.x - c[i].rect_size.x, c[i].rect_position.x)
		c[i].rect_position.y = min(rect_size.y - c[i].rect_size.y, c[i].rect_position.y)
		c[i].rect_position.x = max(0, c[i].rect_position.x)
		c[i].rect_position.y = max(0, c[i].rect_position.y)
	if moved:
		update()
	if !moved:
		set_physics_process(false)

