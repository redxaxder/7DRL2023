tool extends Control

class_name BubblyLog

const fade = preload("res://ui/fade.gd")

export var spd: int = 500
export var spacing: int = 8
export var fade_vec := Vector2(1,1)

func do_fade():
	var top = get_top_active()
	if top != null:
# warning-ignore:return_value_discarded
		fade.new(top, fade_vec)

func get_top_active():
	for c in get_children():
		if !c.get("fading"):
			return c

func spawn(node: Control):
#	var next = TechIcon.new(mu)
	add_child(node)
	node.rect_position.y = rect_size.y

#var spd = 500.0
func _process(delta):
	var dy = spd * delta
	var bottoms = [0]
	var cs = get_children()
	var height = 0
	for c in cs:
		bottoms.append(c.rect_position.y + c.rect_size.y + spacing)
		if !c.get("fading"):
			height += c.rect_size.y + spacing
	for i in get_child_count():
		var c = cs[i]
		c.rect_position.y = max(c.rect_position.y - dy, bottoms[i])
	if height > rect_size.y:
		do_fade()
