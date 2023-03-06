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

func gt(dance: Resource) -> bool:
	if progress() > dance.progress():
		return true
	if type > dance.type:
		return true
	if d8 < dance.d8:
		return true
	if steps < dance.steps:
		return true
	return false

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

func progress() -> int:
	if _progress.size() == 0:
		return 0
	else:
		return _progress[0]

func next_step() -> int:
	return steps[progress()]
