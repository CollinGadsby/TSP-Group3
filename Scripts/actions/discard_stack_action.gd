extends Area2D

@onready var game_manager = get_node("/root/GameScene/GameManager")

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var player = game_manager.get_current_player()
			
			if player.selected_card != null:
				var card_node = player.selected_card
				var card_data = card_node.card_data
				var card_index = player.hand.find(card_data)
				
				animate_discard(card_node, card_index)
			elif game_manager.state == GlobalEnums.GameState.DRAWING:
				game_manager.draw_from_discard()

func animate_discard(card: Node2D, card_index: int) -> void:
	var tween = card.create_tween()
	card.z_index = 100
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)

	var card_half_size = Vector2(50, 67.5)
	var time_seconds = 0.25
	var scale_ratio = Vector2(0.6, 0.6)

	tween.tween_property(card, "global_position", global_position - card_half_size, time_seconds)
	tween.parallel().tween_property(card, "scale", scale_ratio, time_seconds)

	await tween.finished
	card.z_index = 0
	game_manager.discard_card(card_index)
