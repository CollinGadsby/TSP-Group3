extends Area2D

@onready var game_manager = get_node("../../../../GameManager")

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if not game_manager.state == GlobalEnums.GameState.DRAWING:
		return
	if game_manager.draw_stack_lock and game_manager.tutorial_mode:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			game_manager.draw_from_deck()
