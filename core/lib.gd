class_name Core


#returns all positions which may occlude line of sight between v and w
static func los(v: Vector2, w: Vector2) -> Array:
	var d = {}
	for p in bressenham(v,w, false): d[p]=0
	for p in bressenham(w,v, false): d[p]=0
	return d.keys()

# returns all points on the bressenham line from v to w
static func bressenham(v: Vector2, w: Vector2, endpoints = true) -> Array:
	var result = []
	var y0 = int(v.y)
	var y1 = int(w.y)
	var x0 = int(v.x)
	var x1 = int(w.x)
	var dx = abs(x1 - x0)
	var dy = -abs(y1 - y0)
	var sx = sign(x1 - x0)
	var sy = sign(y1 - y0)
	var err = dx + dy
	while true:
		var r = Vector2(x0,y0)
		if endpoints || (r != v && r != w):
			result.append(Vector2(x0,y0))
		if x0 == x1 && y0 == y1: break
		var e2 = 2 * err
		if e2 >= dy:
			if x0 == x1: break
			err += dy
			x0 += sx
		if e2 <= dx:
			if y0 == y1: break
			err += dx
			y0 += sy
	return result

static func manhattan(v: Vector2, w: Vector2) -> float:
	var a = (v-w).abs()
	return a.x + a.y

static func similar(steps1, steps2) -> bool:
	var orbit = D8.orbit(steps1)
	for x in orbit:
		if steps2 == x:
			return true
	return false

static func steps_to_string(steps) -> String:
	var out: String = ""
	for step in steps:
		out += Dir.arrow(step)
	return out

const grace_stages = [20,40,60,80,100,120,140,160,180,200,220,240,260,280,300]
static func grace_info(cumulative_grace: float) -> Dictionary:
	var info = {}
	var cum_grace_stage = 0
	for i in grace_stages.size():
		info["meter"] = cumulative_grace - cum_grace_stage
		info["next"] = grace_stages[i]
		cum_grace_stage += grace_stages[i]
		info["level"] = i
		if cum_grace_stage > cumulative_grace:
			break
	return info

# generate a random sequence of steps
# with no consecutive duplicates
static func gen_steps_ability() -> PoolByteArray:
#	randomize()
	var steps = PoolByteArray()
	steps.append(randi() % 4)
	for i in range(3):
		var x = randi() % 3
		if x >= steps[i]:
			x += 1
		steps.append(x)
	return steps

# generate a random sequence of steps
# with at least one pair of consecutive duplicates
static func gen_steps_dance() -> PoolByteArray:
#	randomize()
	var steps = PoolByteArray()
	var has_match = false
	for i in range(4):
		steps.append(randi() % 4)
		if i > 0 && steps[i] == steps[i-1]:
			has_match = true
	if !has_match: # we will randomly force one to match the previous one
		var ix = (randi() % 3)
		steps[ix + 1] = steps[ix]
	return steps
