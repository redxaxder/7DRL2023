class_name Core


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
