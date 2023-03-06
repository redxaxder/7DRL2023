class_name Core

static func new_game() -> GameState:
	var st = GameState.new()
	var player = Dancer.new()
	st.add_dancer(player)
	return st

static func steps_to_string(steps) -> String:
	var out: String = ""
	for step in steps:
		out += Dir.arrow(step)
	return out

# this calculates the size of the maximum suffix of history
# which is a prefix of goal
static func steps_completed(history, goal) -> int:
	var n = history.size()
	var m = goal.size()
	for x in range(m, 0, -1):
		# example:
		#   history: ABCDEFG      n = 7
		#   goal:        EFGH     m = 4
		#                         shift = 4
		var shift = n - x
		if shift < 0: continue
		var mismatch: bool = false
		for i in range(x):
			if history[i+shift] != goal[i]:
				mismatch = true
				break
		if !mismatch:
			return x
	return 0
