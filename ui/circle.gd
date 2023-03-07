tool
extends Control

class_name Circle

export var detail: int = 20 setget set_detail
export var color: Color = Color(1,1,1) setget set_color

func set_detail(x):
	detail = x
	update()

func set_color(x):
	color = x
	update()

func _radius():
	return min(self.rect_size.x, self.rect_size.y) / 2

func _draw():
	var r = _radius()
	var center = rect_size / 2
	var points = PoolVector2Array()
	for i in range(detail):
		var t = range_lerp(i, 0, detail-1, 0, 2*PI)
		var pt = center + (r * Vector2(cos(t),sin(t)))
		points.append(pt)
		if points.size() >= 3:
			draw_colored_polygon(points,color * modulate,PoolVector2Array(),null,null,true)
