class_name Core

static func new_game() -> GameState:
	var st = GameState.new()
	var player = Dancer.new()
	st.add_dancer(player)
	return st

static func player_move(dir: int, gs: GameState):
	pass
