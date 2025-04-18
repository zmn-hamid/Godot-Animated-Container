extends Control

@onready var responsive: HBoxContainer = $Responsive

func _on_change_order_button_pressed() -> void:
	responsive.move_child(responsive.get_child(-1), 0)

func _on_remove_button_pressed() -> void:
	responsive.remove_child(responsive.get_child(0))

func _on_add_button_pressed() -> void:
	var child = responsive.get_child(-1).duplicate()
	responsive.add_child(child)
	responsive.move_child(child, 0)
