class_name Dir

enum DIR{ UP, LEFT, DOWN, RIGHT }

const NO_DIR = -1

const arrows: PoolStringArray = PoolStringArray(["↑", "←", "↓", "→"])
static func arrow(dir: int) -> String:
	if dir < 0 || dir > 4:
		return ""
	return arrows[dir]

static func dir_to_vec(dir: int) -> Vector2:
	match dir:
		DIR.UP:
			return Vector2(0, -1)
		DIR.DOWN:
			return Vector2(0,1)
		DIR.LEFT:
			return Vector2(-1,0)
		DIR.RIGHT:
			return Vector2(1,0)
	return Vector2(0,0)

static func rot(dir: int, clockwise: bool = false) -> int:
	if clockwise:
		return (dir + 3) % 4
	else:
		return (dir + 1) % 4

static func invert(dir: int) -> int:
	return (dir + 2) % 4

static func mv(v: Vector2, d: int) -> Vector2:
	return v + dir_to_vec(d)

# which direction does w need to move to approach w
static func approach(v: Vector2, w: Vector2) -> Array:
	var results = []
	if v.x < w.x:
		results.append(DIR.RIGHT)
	if v.x > w.x:
		results.append(DIR.LEFT)
	if v.y < w.y:
		results.append(DIR.DOWN) #note: y axis points down
	if v.y > w.y:
		results.append(DIR.UP) #note: y axis points down
	return results
