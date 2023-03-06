class_name Core

static func steps_to_string(steps) -> String:
	var out: String = ""
	for step in steps:
		out += Dir.arrow(step)
	return out

# this calculates the size of the maximum suffix of history
# which is a prefix of goal
static func steps_progress(history, goal) -> int:
	for x in range(goal.size()-1, 0, -1):
		if _check_steps_match(history, goal, x):
			return x
	return 0

static func _check_steps_match(history, goal, x: int) -> bool:
		# example:
		#   history: ABCDEFG      n = 7
		#   goal:        EFGH     m = 4
		#                         x = 3
		#                         shift = 4
	var n = history.size()
	var shift = n - x
	if shift < 0:
		return false
	for i in range(x):
		if history[i+shift] != goal[i]:
			return false
	return true
	
static func is_complete(history, goal) -> bool:
	return _check_steps_match(history, goal, goal.size())

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
	randomize()
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
	randomize()
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
