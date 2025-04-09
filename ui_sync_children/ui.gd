extends Control

@onready var responsive: HBoxContainer = $Responsive
@onready var actual: Control = $Actual

# maps responsive children to their equivalent actual children
var mapped: Dictionary = {} # {responsive_child: actual_child}
# tracks the previous properties of the responsive children to calulate the changes
var tracked: Dictionary = {} # {responsive_child: properties}

# to avoid overhead
# the rest is handled via child_order_changed signal
var is_initialized: bool = false

var tween: Tween


func _ready() -> void:
	responsive.child_order_changed.connect(_on_child_order_changed)

func _process(_delta: float) -> void:
	if not is_initialized:
		start_sync()
		is_initialized = true

func _on_child_order_changed() -> void:
	"""checks if child order is changed to update the actual nodes"""
	if is_initialized and is_inside_tree():
		await get_tree().process_frame
		start_sync()

func start_sync() -> void:
	"""updates $Actual children to sync with $Responsive"""
	if tween and tween.is_running():
		await tween.finished
	var responsive_children = responsive.get_children()
	
	# check for removal of children
	for res_child in mapped:
		var act_child = mapped[res_child]
		if res_child not in responsive_children:
			actual.remove_child(act_child)
			mapped.erase(res_child)
	
	# check for changes to the existing children
	for res_child in responsive_children:
		if res_child not in mapped:
			# is a new child
			var act_child = res_child.duplicate()
			actual.add_child(act_child)
			mapped[res_child] = act_child
		sync_core(res_child, responsive_children.find(res_child))

func sync_core(res_child, res_child_idx: int) -> void:
	"""core function that syncs and tracks"""
	if res_child not in tracked.keys():
		# is a new child
		# default global_position is zero
		tracked[res_child] = {"global_position": Vector2.ZERO}
	# get the equivalent actual child
	var act_child = mapped[res_child]
	# calculate the changes made to the responsive child
	var difference = res_child.global_position - tracked[res_child]["global_position"]
	# add the changes to the actual child
	tween_child(act_child, null, act_child.global_position + difference)
	# update the tracked properties to match the responsive child
	tracked[res_child]["global_position"] = res_child.global_position
	# move the actual child to the correct index to match the order of responsive children
	# this doesn't do anything with the visuals but will keep maintainability
	actual.move_child(act_child, res_child_idx)

func tween_child(act_child, from, to) -> void:
	"""animates the $Actual child"""
	tween = create_tween().set_parallel()
	tween.tween_property(
		act_child,
		"global_position",
		to,
		.2,
	).from(from if from else act_child.global_position)

### buttons

func _on_change_order_button_pressed() -> void:
	responsive.move_child(responsive.get_child(-1), 0)

func _on_remove_button_pressed() -> void:
	responsive.remove_child(responsive.get_child(0))

func _on_add_button_pressed() -> void:
	var child = responsive.get_child(-1).duplicate()
	responsive.add_child(child)
	responsive.move_child(child, 0)

func _on_change_position_pressed() -> void:
	actual.get_child(-1).global_position.y -= 100
