extends Control

@onready var responsive: HBoxContainer = $Responsive
@onready var actual: Control = $Actual

var mapped: Dictionary = {} # {responsive_child: actual_child}

func _process(_delta: float) -> void:
	check_for_changes()

func check_for_changes():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT) \
				.set_trans(Tween.TRANS_CUBIC).set_parallel()

	var responsive_children = responsive.get_children()
	
	# check for removal
	for mapped_res_child in mapped.keys():
		var mapped_act_child = mapped[mapped_res_child]
		if mapped_res_child not in responsive_children:
			actual.remove_child(mapped_act_child)
			mapped.erase(mapped_res_child)
	
	# check for addition and re-position
	for res_child in responsive_children:
		if res_child in mapped.keys():
			# is not a new node
			var mapped_actual_child = mapped[res_child]
			if res_child.global_position != mapped_actual_child.global_position:
				# needs re-position
				tween.tween_property(
					mapped_actual_child,
					"global_position",
					res_child.global_position,
					.1,
				)
		else:
			# is a new node
			var dup = res_child.duplicate()
			actual.add_child(dup)
			mapped[res_child] = dup
			dup.global_position = res_child.global_position


### tracked buttons

func _on_change_order_button_pressed() -> void:
	responsive.move_child(responsive.get_child(-1), 0)

func _on_remove_button_pressed() -> void:
	responsive.remove_child(responsive.get_child(0))

func _on_add_button_pressed() -> void:
	var c = responsive.get_child(0).duplicate()
	responsive.add_child(c)
