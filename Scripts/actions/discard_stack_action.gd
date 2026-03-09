extends Area2D

@onready var game_manager = get_node("/root/GameScene/GameManager")

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			game_manager.draw_from_discard()
