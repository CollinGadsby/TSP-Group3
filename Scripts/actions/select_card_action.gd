extends Area2D

@onready var game_manager = get_node("/root/GameScene/GameManager")

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Pressed")
			var card_node = get_parent().get_parent()
			var card_data = card_node.card_data 
			
			var player_hand = game_manager.get_current_player().hand
			for c in player_hand:
				print("CP: ", game_manager.current_player_index)
				print("R: ", c.rank, " S: ", c.suit)
			var card_index = player_hand.find(card_data)
			
			if card_index != -1:
				game_manager.discard_card(card_index)
			else:
				print("Card not found in player's hand!")
