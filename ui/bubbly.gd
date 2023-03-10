tool extends Control

#const TechIcon = preload("res://kungfu/techniques/lib/tech_icon.gd")
#const mu = preload("res://kungfu/techniques/data/flow.tres")
const fade = preload("res://fade.gd")

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
	var t = [0]
	var b = [0]
	var cs = get_children()
	for c in cs:
		t.append(c.rect_position.y)
		b.append(c.rect_position.y + c.rect_size.y + spacing)
	for i in get_child_count():
		var c = cs[i]
		c.rect_position.y = max(c.rect_position.y - dy, b[i])
