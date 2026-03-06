extends Area2D

signal card_action(left:bool)
signal card_release(left: bool)
signal card_clicked(left: bool)  

var press_position: Vector2

func _input_event(_viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("ClickL"):
		press_position = get_global_mouse_position()
		card_action.emit(true)
	if event.is_action_pressed("ClickR"):
		press_position = get_global_mouse_position()
		card_action.emit(false)
	if event.is_action_released("ClickL"):
		card_release.emit(true)
		if global_position.distance_to(press_position) < 5:
			card_clicked.emit(true)
	if event.is_action_released("ClickR"):
		card_release.emit(false)
		if global_position.distance_to(press_position) < 5:
			card_clicked.emit(false)
		
	pass
