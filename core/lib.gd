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
