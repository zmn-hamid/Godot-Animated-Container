extends Control

@onready var responsive: HBoxContainer = $Responsive
@onready var actual: Control = $Actual

var mapped: Dictionary = {} # {responsive_child: actual_child}

var init: bool = false

func _ready() -> void:
	responsive.child_order_changed.connect(_on_child_order_changed)

func _process(_delta: float) -> void:
	if not init:
		# to avoid overhead, only initialize.
		# the rest is handled via child_order_changed signal
		synchronize_actual()
		init = true

func _on_child_order_changed() -> void:
	"""checks if child order is changed to update the actual nodes"""
	if init:
		if get_tree():
			await get_tree().process_frame
		synchronize_actual()

func synchronize_actual():
	"""updates $Actual children to sync with $Responsive"""
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
				var tween = create_tween().set_parallel()
				tween.tween_property(
					mapped_actual_child,
					"global_position",
					res_child.global_position,
					.2,
				)
				actual.move_child(mapped_actual_child, responsive_children.find(res_child))
		else:
			# is a new node
			var dup = res_child.duplicate()
			actual.add_child(dup)
			actual.move_child(dup, responsive_children.find(res_child))
			mapped[res_child] = dup
			dup.global_position = res_child.global_position


### buttons

func _on_change_order_button_pressed() -> void:
	responsive.move_child(responsive.get_child(-1), 0)

func _on_remove_button_pressed() -> void:
	responsive.remove_child(responsive.get_child(0))

func _on_add_button_pressed() -> void:
	var child = responsive.get_child(-1).duplicate()
	responsive.add_child(child)
	responsive.move_child(child, 0)
