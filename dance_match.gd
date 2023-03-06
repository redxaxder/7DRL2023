extends VBoxContainer


func _ready():
	pass # Replace with function body.

func snap():
	for c in get_children():
		c.snap()

func sort_children():
	var a = get_children()
	a.sort_custom(self, "compare_children")
	for i in a.size():
		self.move_child(a[i],i)
#		if a[i].prev_index > i:
#			a[i].kick_right()
#		a[i].prev_index = i
	
func compare_children(l: Node, r: Node) -> bool:
#	sanity_check_comparison(l.dance, r.dance)
	return l.dance.compare(r.dance) < 0


#func custom_sort_matches(l: Node, r: Node) -> bool:
#       if l.progress > r.progress:
#               return true
#       elif r.progress > l.progress:
#               return false
#       if l.sortkey1 > r.sortkey1:
#               return true
#       elif r.sortkey1 > l.sortkey1:
#-               return false
#-       return l.sortkey2 > r.sortkey2
