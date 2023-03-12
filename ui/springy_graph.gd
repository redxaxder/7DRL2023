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
export var edge_color: Color = Color(0.7,0.7,0.7)

export var focus_index: int = -1 setget set_focus_index
export var focus_edge_width: float = 3.0
export var focus_edge_color: Color = Color(1,1,1)


signal npc_focus(npc)
signal npc_unfocus
signal npc_click(npc)

var _velocities: PoolVector2Array

func _ready():
	for c in self.get_children():
		c.connect("item_rect_changed", self, "_refresh")
	_refresh()

func add_child(node: Node, legible_unique_name: bool = false):
# warning-ignore:return_value_discarded
	node.connect("item_rect_changed", self, "_refresh")
# warning-ignore:return_value_discarded
	node.connect("mouse_entered", self, "_on_node_hover", [node])
# warning-ignore:return_value_discarded
	node.connect("mouse_exited", self, "_on_node_unhover")
# warning-ignore:return_value_discarded
	node.connect("clicked", self, "_on_node_click", [node])
	.add_child(node, legible_unique_name)
	_refresh()

func set_springs(x):
	springs = x
	_refresh()

func set_has_anchor(x):
	has_anchor = x
	_refresh()

func set_focus_index(x):
	focus_index = x
	update()

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
	update_visible_support()
	_refresh()

func remove_spring(i: int, j: int):
	var v = Vector2(min(i,j),max(i,j))
	var new_springs = PoolVector2Array()
	for s in springs:
		if v != s:
			new_springs.append(s)
	springs = new_springs
	update_visible_support()
	_refresh()

func _refresh():
	if _velocities.size() != get_child_count():
		_velocities = PoolVector2Array()
		for c in get_children():
			_velocities.append(Vector2.ZERO)
	set_physics_process(true)

func visible_neighbors(i) -> Array:
	var result = []
	var c = get_children()
	for s in springs:
		if !c[s.x].visible || !c[s.y].visible:
			continue
		if s.x == i:
			result.append(c[s.y])
		if s.y == i:
			result.append(c[s.x])
	return result

func update_vertex(i):
	var vertex = get_child(i)
	vertex.displayed_faction = vertex.npc.faction

func update_visible_support():
	var numerators = []
	var denominators = []
	for i in get_child_count():
		numerators.append(0)
		denominators.append(0)
	var cs = get_children()
	for s in springs:
		if s.x >= cs.size(): continue
		if s.y >= cs.size(): continue
		if !cs[s.x].visible || !cs[s.y].visible:
			continue
		denominators[s.x] += 1
		denominators[s.y] += 1
		if get_child(s.x).displayed_faction == NPC.SUPPORT:
			numerators[s.y] += 1
		if get_child(s.y).displayed_faction == NPC.SUPPORT:
			numerators[s.x] += 1
	for i in get_child_count():
		if denominators[i] > 0:
			get_child(i).support = float(100 * numerators[i]) / float(denominators[i])

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

		var is_focus_spring = s.x == focus_index || s.y == focus_index
		if is_focus_spring:
			draw_line(edge_start,edge_end,focus_edge_color, focus_edge_width, true)
		else:
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

func _on_node_hover(vertex: Node):
	self.focus_index = vertex.get_index()
	emit_signal("npc_focus", vertex.npc)

func _on_node_unhover():
	self.focus_index = -1
	emit_signal("npc_unfocus")

func _on_node_click(vertex):
	emit_signal("npc_click", vertex.npc)

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if !visible: self.focus_index = -1
