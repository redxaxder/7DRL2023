extends VBoxContainer

func snap():
	for c in get_children():
		c.snap()

func sort_children():
	var a = get_children()
	var n = a.size()
	a.sort_custom(self, "compare_children")
	for i in a.size():
		var c: Control = a[i]
		self.move_child(c,i)
		c.ix = i
		VisualServer.canvas_item_set_draw_index(a[i].get_canvas_item(), n-i)
	
func compare_children(l: Node, r: Node) -> bool:
	return l.dance.compare(r.dance) < 0
