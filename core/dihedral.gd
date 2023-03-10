class_name D8

enum G{ E, P, P2, P3, R, RP, RP2, RP3 }

const names = ["e", "p", "p2", "p3", "r", "rp", "rp2", "rp3"]
const inverses = [ G.E, G.P3, G.P2, G.P, G.R, G.RP, G.RP2, G.RP3 ]
static func name(g: int) -> String:
	if g < 0 || g > 8:
		return ""
	else:
		return names[g]

static func invert(g: int) -> int:
	if g < 0 || g > 8:
		return 0
	else:
		return inverses[g]

static func act_dir(g: int, dir: int) -> int:
	var rot = g & 3
	var flip = g & 4
	var result = (dir + rot) & 3
	if flip > 0  && (result & 1) > 0:
		# up (0x00) & down (0x10) left: constant
		# left (0x01) <-> right (0x11): swap
		result = result ^ 2
	return result

static func act_vec(g: int, v: Vector2) -> Vector2:
	var rot = g & 3
	var flip = g & 4
	var r: Vector2 = v
	# one level of rotation goes anticlockwise
	# up -> left -> down -> right -> up
	# also, the y axis points down, so:
	# up(0,-1) -> left(-1,0) -> down(0,1) -> right(1,0)
	match rot:
		0: pass
		1: r = Vector2(r.y,-r.x)
		2: r *= -1
		3: r = Vector2(-r.y,r.x)
	if flip > 0: # this is a left/right flip
		r.x = -r.x
	return r

static func act_steps(g: int, steps) -> PoolByteArray:
	var result = PoolByteArray()
	for dir in steps:
		result.append(act_dir(g, dir))
	return result

static func orbit(steps) -> Array:
	var dict: Dictionary = {}
	for g in range(8):
		var x = act_steps(g, steps)
		if dict.has(x):
			continue # in the case of collision, we keep the first element
		else:
			dict[x] = g
	var results = []
	results.resize(dict.size())
	for k in dict.keys():
		results[dict[k]] = k
	return results
