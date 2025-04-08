extends HBoxContainer


var pre_sort_positions := {}

func _notification(what):
	if what == NOTIFICATION_PRE_SORT_CHILDREN:
		pre_sort_positions.clear()
		for child in get_children():
			if child is Control:
				pre_sort_positions[child] = child.position
	elif what == NOTIFICATION_SORT_CHILDREN:
		for child in get_children():
			if child is Control:
				var final_position = child.position
				create_tween().set_parallel().tween_property(
					child,
					"position",
					final_position,
					0.2).from(pre_sort_positions[child])
