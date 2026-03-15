extends Area2D

@onready var game_manager = get_node("../../../../GameManager")

signal select_card_sig(card_data: CardData)

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if not game_manager.state == GlobalEnums.GameState.DISCARDING:
		return
	if game_manager.tutorial_mode and game_manager.select_lock:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var card_node = get_parent().get_parent()
			var select_offset = 40
				
			# No selected card
			if game_manager.get_current_player().selected_card == null:
				game_manager.get_current_player().selected_card = card_node # Update Selected Card
				animate_card(card_node, card_node.position.y - select_offset)
				emit_signal("select_card_sig", card_node.card_data)
			else: # Had a card selected
				if game_manager.get_current_player().selected_card == card_node: # Deselecting card
					animate_card(card_node, card_node.position.y + select_offset)
					game_manager.get_current_player().selected_card = null
				else: # Swapping Selection
					var old_card = game_manager.get_current_player().selected_card
					animate_card(old_card, old_card.position.y + select_offset)
					
					game_manager.get_current_player().selected_card = card_node
					animate_card(card_node, card_node.position.y - select_offset)
					emit_signal("select_card_sig", card_node.card_data)
					

func animate_card(card: Node2D, target_y: float):
	var tween = card.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card, "position:y", target_y, 0.15)
