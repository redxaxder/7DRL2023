extends Resource

class_name Dance
# state machine for modeling progress through dance matches

export var steps: PoolByteArray = PoolByteArray()
export (int, "Grace") var type: int = 0
export var _progress: PoolByteArray = PoolByteArray()
export var d8: int = 0

signal matched
signal mismatch

enum TYPE { GRACE }

func _init(_steps = PoolByteArray(), _type = 0, _d8: int = 0):
	steps = PoolByteArray(_steps)
	type = _type
	d8 = _d8

func base_steps():
	var inv = D8.invert(d8)
	return  D8.act_steps(inv, steps)

func compare(dance: Resource) -> int:
	var mine = [-progress(), -type, d8]
	var theirs = [-dance.progress(), -dance.type, dance.d8]
	for i in range(3):
		if mine[i] < theirs[i]:
			return -1
		if theirs[i] < mine[i]:
			return 1
	return compare_bytes(base_steps(), dance.base_steps())

static func compare_bytes(l: PoolByteArray, r: PoolByteArray) -> int:
	var n = l.size()
	var m = r.size()
	for i in range(n):
		if i >= m: #shorter string sorts first
			return -1
		if l[i] < r[i]:
			return -1
		if r[i] < l[i]:
			return 1
	return 0

enum MATCH { PROGRESS, RESET, FINISH }
func transition(dir: int) -> int:
	var result = MATCH.PROGRESS
	var n = steps.size()
	var next = PoolByteArray()
	for i in _progress.size():
		var p = _progress[i]
		if steps[p] == dir:
			if p + 1 >= n:
				result = MATCH.FINISH
				emit_signal("matched")
			else:
				next.append(p+1)
		elif i == 0:
			result = MATCH.RESET
			emit_signal("mismatch") #progress was lost
	if dir == steps[0]:
		next.append(1)
	_progress = next
	return result

# what is the longest sequence that a step in this direction would create
func evaluate(dir: int) -> int:
	var result = 0
	for p in _progress:
		if steps[p] == dir:
			result = max(p+1, result)
	return result

func progress() -> int:
	if _progress.size() == 0:
		return 0
	else:
		return _progress[0]

func next_step() -> int:
	return steps[progress()]
