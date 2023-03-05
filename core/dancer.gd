extends Resource

class_name Dancer

export var pos: Vector2 = Vector2(0,0)
export var id: int = 0

export var recent_moves: Array = []

const max_memory = 4

func remember_move(dir: int):
	recent_moves.append(dir)
	while recent_moves.size() > max_memory:
		recent_moves.pop_front()
