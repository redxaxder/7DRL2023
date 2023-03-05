class_name D8

enum G{ E, P, P2, P3, R, RP, RP2, RP3 }

const names = ["e", "p", "p2", "p3", "r", "rp", "rp2", "rp3"]

static func name(g: int) -> String:
	if g < 0 || g > 8:
		return ""
	else:
		return names[g]

static func act_dir(g: int, dir: int) -> int:
	var rot = g && 3
	var flip = g && 4
	var result = Dir.rot(dir, rot)
	if flip > 0:
		result = Dir.invert(result)
	return result

static func act_steps(g: int, steps) -> PoolIntArray:
	var result = PoolIntArray()
	for dir in steps:
		result.append(act_dir(g, dir))
	return result
