class_name D8

enum G{ E, P, P2, P3, R, RP, RP2, RP3 }

const names = ["e", "p", "p2", "p3", "r", "rp", "rp2", "rp3"]

static func name(g: int) -> String:
	if g < 0 || g > 8:
		return ""
	else:
		return names[g]

static func act_dir(g: int, dir: int) -> int:
	var rot = g & 3
	var flip = g & 4
	var result = (dir + rot) & 3
	if flip > 0  && (result & 1) > 0:
		# up (0x00) & down (0x10) left: constant
		# left (0x01) <-> right (0x11): swap
		result = result ^ 2
	return result

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
